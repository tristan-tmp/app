require 'rubygems'
require 'bundler/setup'
require 'json'
require 'ipaddress'

INSTANCE_TYPES = %w( t2.micro t2.small t3.medium)
VALID_INSTANCES = Hash[INSTANCE_TYPES.zip(INSTANCE_TYPES)]

# Generate outputs
def generate_outputs
  {
    'PublicIP' => {
      'Description' => 'Public IP address of the newly created EC2 instance',
      'Value' => {
        'Fn::GetAtt' => %w(EC2Instance PublicIp) } }
  }
end

# AWS baby!
class Aws
  # Generate instance security group
  # rubocop:disable MethodLength
  def generate_instance_security_group(iprange)
    {
      'Properties' => {
        'GroupDescription' =>
          'Enable SSH access via port 22',
        'SecurityGroupIngress' => [{
          'CidrIp' => iprange,
          'FromPort' => '22',
          'IpProtocol' => 'tcp',
          'ToPort' => '22' }] },
      'Type' => 'AWS::EC2::SecurityGroup'
    }
  end

  # Generate resources
  # rubocop:disable MethodLength
  def generate_resources(num_instances = 1, instance_type = 't2.micro',
  cidr_ip = '0.0.0.0/0')

    num_instances = 1 unless num_instances > 0

    # Check for emtpy instance_type variable
    instance_type = instance_type.nil? || instance_type.empty? ? 't2.micro' : instance_type

    # Check for valid ip address format
    cidr_ip = '0.0.0.0/0' unless IPAddress.valid_ipv4? cidr_ip

    # Check for valid instance types
    instance_type = VALID_INSTANCES.fetch(instance_type, 't2.micro')

    # Nifty CIDR converting
    iprange = IPAddress::IPv4.new cidr_ip

    result = {}
    num = 0
    while num < num_instances
      ec2_num = num + 1
      instance_properties = {
        'Properties' => {
          'ImageId' => 'ami-b97a12ce',
          'InstanceType' => instance_type,
          'SecurityGroups' => [{
            'Ref' => 'InstanceSecurityGroup' }] },
        'Type' => 'AWS::EC2::Instance' }

      if ec2_num == 1
        result['EC2Instance'] = instance_properties
      else
        result["EC2Instance#{ec2_num}"] = instance_properties
      end
      num += 1
    end

    result['InstanceSecurityGroup'] =
    generate_instance_security_group(iprange.to_string)

    # Return complete result
    result
  end

  # Generate data used for JSON
  def generate_json_data(num_instances, instance_type, cidr_ip)
    outputs = generate_outputs
    resources = generate_resources(num_instances, instance_type, cidr_ip)

    {
      'AWSTemplateFormatVersion' => '2010-09-09',
      'Outputs' => outputs,
      'Resources' => resources
    }
  end
end
