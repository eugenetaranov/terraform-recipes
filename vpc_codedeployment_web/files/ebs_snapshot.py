import boto3
import datetime


TAG_FILTER = { 'Name': 'tag:backup', 'Values': ['true'] }
KEEP_DAYS = 7


class AWS_EBS(object):
    def __init__(self):
        self.client = boto3.client('ec2')
        self.resource = boto3.resource('ec2')
        self.volumes = []
        self.snapshots = []


    def find_volumes(self):
        res = self.client.describe_volumes(Filters=[TAG_FILTER, { 'Name': 'attachment.status', 'Values': ['attached'] }])

        if res['ResponseMetadata']['HTTPStatusCode'] != 200:
            print "Got incorrect response from AWS, http code:{}" % res['ResponseMetadata']['HTTPStatusCode']
            exit(1)

        self.volumes = map( lambda x: {'instanceid': x['Attachments'][0]['InstanceId'], 'tags': x['Tags'], 'volumeid': x['VolumeId'] }, res['Volumes'])


    def create_snapshot(self, volume):
        v = self.resource.Volume(volume["volumeid"])
        snapshot = v.create_snapshot(DryRun=False) #snapshot started

        tags = filter( lambda x:  x['Key'] != 'backup' ,volume['tags']) #copy volume tags to snapshot without @backup
        delete_at = (datetime.datetime.now() + datetime.timedelta(days=KEEP_DAYS)).strftime('%Y-%m-%d')
        tags.append({'Key': 'delete_at', 'Value': delete_at}) #added delete_at tag
        snapshot.create_tags(DryRun=False, Tags=tags)


    def find_snapshots(self):
        today = datetime.datetime.now().strftime('%Y-%m-%d')
        res = self.client.describe_snapshots(DryRun=False, OwnerIds=['self'], Filters=[{'Name': 'tag:delete_at', 'Values': [today]}])

        if res['ResponseMetadata']['HTTPStatusCode'] != 200:
            print "Got incorrect response from AWS, http code:{}" % res['ResponseMetadata']['HTTPStatusCode']
            exit(1)

        self.snapshots = map( lambda x: x['SnapshotId'], res['Snapshots'])


    def delete_snapshot(self, snapshot):
        print 'Deleting snapshot {}'.format(snapshot)
        self.client.delete_snapshot(DryRun=False, SnapshotId=snapshot)


def lambda_handler(event, context):
    ebs = AWS_EBS()
    ebs.find_volumes()
    ebs.find_snapshots()

    print 'Found the following volumes to back up: {}'.format(', '.join(map(lambda x: x['volumeid'], ebs.volumes)))
    print 'Found the following snapshots: {}'.format(', '.join(ebs.snapshots))

    for volume in ebs.volumes:
        ebs.create_snapshot(volume)

    for snapshot in ebs.snapshots:
        ebs.delete_snapshot(snapshot)
