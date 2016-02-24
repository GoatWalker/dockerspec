# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2016 Xabier de Zuazo
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

require 'dockerspec/runner/docker'
require 'dockerspec/runner/compose'

module Dockerspec
  #
  # Saves internal configuration for {Dockerspec}.
  #
  # - The test engines to Run: Specinfra, ...
  # - The internal library used to run Docker.
  #
  class Configuration
    #
    # The {Dockerspec::Runner} class used to run Docker.
    #
    # @return [Class] The {Dockerspec::Runner::Base} class.
    #
    attr_accessor :docker_runner

    #
    # The {Dockerspec::Runner::Compose} class used to run Docker Compose.
    #
    # @return [Class] The {Dockerspec::Runner::Compose} class.
    #
    attr_accessor :compose_runner

    #
    # A list of test engines used to run the tests.
    #
    # @return [Array<Class>] A list of {Dockerspec::Engine::Base} classes.
    #
    attr_reader :engines

    class << self
      #
      # Adds a class to use as engine to run the tests.
      #
      # @example
      #   Dockerspec.Configuration.add_engine Dockerspec::Engine::Specinfra
      #
      # @param engine [Class] A {Dockerspec::Engine::Base} subclass.
      #
      # @return void
      #
      # @api public
      #
      def add_engine(engine)
        instance.add_engine(engine)
      end

      #
      # Gets the engine classes used to run the tests.
      #
      # @return [Array<Class>] A list of {Dockerspec::Engine::Base} subclasses.
      #
      # @api public
      #
      def engines
        instance.engines
      end

      #
      # Sets the class used to create and start Docker Containers.
      #
      # @example
      #   Dockerspec.Configuration.docker_runner = Dockerspec::Runner::Docker
      #
      # @param runner [Class] A {Dockerspec::Runner::Base} subclass.
      #
      # @return void
      #
      # @api public
      #
      def docker_runner=(runner)
        instance.docker_runner = runner
      end

      #
      # Gets the class used to create and start Docker Containers.
      #
      # @return [Class] A {Dockerspec::Runner::Base} subclass.
      #
      # @api public
      #
      def docker_runner
        instance.docker_runner
      end

      #
      # Sets the class used to start Docker Compose.
      #
      # @example
      #   Dockerspec.Configuration.compose_runner = Dockerspec::Runner::Compose
      #
      # @param runner [Class] A {Dockerspec::Runner::Compose::Base} subclass.
      #
      # @return void
      #
      # @api public
      #
      def compose_runner=(runner)
        instance.compose_runner = runner
      end

      #
      # Gets the class used to start Docker Compose.
      #
      # @return [Class] A {Dockerspec::Runner::Compose::Base} subclass.
      #
      # @api public
      #
      def compose_runner
        instance.compose_runner
      end

      #
      # Resets the internal Configuration singleton object.
      #
      # @return void
      #
      # @api public
      #
      def reset
        @instance = nil
      end

      protected

      #
      # Creates the Configuration singleton instance.
      #
      # @return void
      #
      # @api private
      #
      def instance
        @instance ||= new
      end
    end

    #
    # Adds a class to use as engine to run the tests.
    #
    # @param engine [Class] A {Dockerspec::Engine::Base} subclass.
    #
    # @return void
    #
    # @api private
    #
    def add_engine(engine)
      @engines << engine
      @engines.uniq!
    end

    protected

    #
    # Constructs a configuration object.
    #
    # @return [Dockerspec::Configuretion] The configuration object.
    #
    # @api private
    #
    def initialize
      @docker_runner = Runner::Docker
      @compose_runner = Runner::Compose
      @engines = []
    end
  end
end
