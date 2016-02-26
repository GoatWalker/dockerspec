# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2015-2016 Xabier de Zuazo
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe Dockerspec::Runner::Serverspec::Docker do
  let(:builder) { double('Dockerspec::Builder') }
  let(:options) { {} }
  subject { described_class.new('tag', options) }
  let(:image_id) { '8d5e6665a7a6' }
  let(:configuration) { double('Specinfra::Configuration') }
  let(:container_json) { { 'Image' => image_id } }
  let(:container) { double('Docker::Container', json: container_json) }
  let(:specinfra_backend) { double('Dockerspec::Engine::Specinfra::Backend') }
  before do
    @engines_orig = Dockerspec::Configuration.engines.dup
    Dockerspec::Configuration.engines.replace([Dockerspec::Engine::Specinfra])
    allow(ObjectSpace).to receive(:define_finalizer)
    allow(Specinfra).to receive(:configuration).and_return(configuration)
    allow(Dockerspec::Helper::Docker).to receive(:lxc_execution_driver?)
      .and_return(false)
    allow(Docker::Container).to receive(:create).and_return(container)
    allow(Docker::Container).to receive(:get).and_return(container)
    allow(configuration).to receive(:backend)
    allow(configuration).to receive(:os)
    allow(configuration).to receive(:docker_image)
    allow(configuration).to receive(:docker_container)
    allow_any_instance_of(described_class).to receive(:id).and_return(nil)
    allow_any_instance_of(described_class)
      .to receive(:image_id).and_return(image_id)

    allow(Dockerspec::Engine::Specinfra::Backend)
      .to receive(:new).and_return(specinfra_backend)
    allow(specinfra_backend).to receive(:reset)
    allow(specinfra_backend).to receive(:save)
    allow(specinfra_backend).to receive(:backend_instance_attribute)
      .with(:container).and_return(container)

    allow(Dockerspec::Builder).to receive(:new).and_return(builder)
    allow(builder).to receive(:build).and_return(builder)
  end
  after { Dockerspec::Configuration.engines.replace(@engines_orig) }

  context '.new' do
    it 'runs without errors' do
      subject
    end
  end

  context '#container' do
    let(:container) { double('Docker::Container') }

    it 'returns backend container attribute' do
      expect(specinfra_backend).to receive(:backend_instance_attribute).once
        .with(:container).and_return(container)
      expect(subject.container).to eq(container)
    end
  end

  context '#run' do
    it 'runs without errors' do
      subject.run
    end

    it 'can set Specinfra OS family' do
      subject = described_class.new('tag', family: 'alpine')
      expect(configuration).to receive(:os).once.with(family: 'alpine')
      subject.run
    end

    it 'sets Specinfra image ID' do
      expect(configuration).to receive(:docker_image).once.with(image_id)
      subject.run
    end

    it 'sets the environment' do
      options[:env] = { PASSWORD: 'example' }
      expect(configuration).to receive(:env).once.with(options[:env]).ordered
      expect(configuration).to receive(:docker_image).once.with(image_id)
        .ordered
      subject.run
    end

    context 'with a container ID' do
      let(:id) { '1a895dd3954a' }
      subject { described_class.new(id: id) }
      before { expect(subject).to receive(:id).and_return(id).at_least(1) }

      it 'sets Specinfra container ID' do
        expect(configuration).to receive(:docker_container).once.with(id)
        subject.run
      end
    end

    context 'with native execution driver' do
      before do
        expect(Dockerspec::Helper::Docker).to receive(:lxc_execution_driver?)
          .and_return(false)
      end

      it 'uses docker_lxc backend' do
        expect(configuration).to receive(:backend).once.with(:docker)
        subject.run
      end
    end

    context 'with LXC execution driver' do
      before do
        expect(Dockerspec::Helper::Docker).to receive(:lxc_execution_driver?)
          .and_return(true)
      end

      it 'uses docker_lxc backend' do
        expect(configuration).to receive(:backend).once.with(:docker_lxc)
        subject.run
      end
    end

    {
      docker: :docker,
      native: :docker,
      docker_lxc: :docker_lxc,
      lxc: :docker_lxc,
      docker_other: :docker_other,
      other: :docker_other
    }.each do |name, value|
      context "with #{name.inspect} as backend" do
        subject { described_class.new('build', backend: name) }

        it "uses #{value.inspect} as Specinfra backend" do
          expect(configuration).to receive(:backend).once.with(value)
          subject.run
        end
      end
    end

    it 'saves the specinfra backend' do
      expect(specinfra_backend).to receive(:save).once
      subject.run
    end

    context 'with run errors' do
      let(:error_msg) { DockerspecTests.error_example }
      before do
        expect(configuration).to receive(:backend)
          .and_raise Docker::Error::DockerError.new(error_msg)
      end

      it 'raises a docker error' do
        expect { subject.run }.to raise_error Dockerspec::DockerError
      end
    end
  end # context #run

  context '#finalize' do
    it 'does not stop the container' do
      expect(container).to_not receive(:stop)
      subject.finalize
    end

    it 'does not delete the container' do
      expect(container).to_not receive(:delete)
      subject.finalize
    end
  end

  context '#to_s' do
    it 'returns the description' do
      expect(subject.to_s).to match(/^Serverspec on/)
    end
  end

  context '#restore_rspec_context' do
    it 'restores the specinfra backend' do
      expect(specinfra_backend).to receive(:restore).once
      subject.run
      subject.restore_rspec_context
    end
  end
end
