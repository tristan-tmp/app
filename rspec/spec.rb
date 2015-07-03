require_relative '../assignment'

describe '.generate_resources' do
  before do
    @aws = Aws.new
  end

  context 'with correct arguments' do
    it 'hash hash 3 levels' do
      result = @aws.generate_resources(2, 't2.small', '8.8.8.8')

      expect(result.size).to eq(3)
    end
    it 'InstanceType equals t2.small' do
      result = @aws.generate_resources(2, 't2.small', '8.8.8.8')

      expect(result['EC2Instance2']['Properties'] \
        ['InstanceType']).to eq('t2.small')
    end
    it 'CIDR equals given ipaddress/32' do
      result = @aws.generate_resources(2, 't2.small', '8.8.8.8')

      expect(result['InstanceSecurityGroup']['Properties'] \
        ['SecurityGroupIngress'][0]['CidrIp']).to eq('8.8.8.8/32')
    end
  end

  context 'with wrong arguments' do
    it 'hash should return to default of 2 levels' do
      result = @aws.generate_resources(0, '', '2')

      expect(result.size).to eq(2)
    end

    it 'InstanceType should be default' do
      result = @aws.generate_resources(0, '', '2')

      expect(result['EC2Instance']['Properties'] \
      ['InstanceType']).to eq('t2.micro')
    end

    it 'CidrIp should equal to default value' do
      result = @aws.generate_resources(0, '', '2')

      expect(result['InstanceSecurityGroup']['Properties'] \
      ['SecurityGroupIngress'][0]['CidrIp']).to eq('0.0.0.0/0')
    end
  end
end
