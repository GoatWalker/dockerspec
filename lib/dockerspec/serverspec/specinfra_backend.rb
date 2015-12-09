# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2015 Xabier de Zuazo
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

require 'specinfra/backend/base'
require 'dockerspec/serverspec/specinfra_hack'

module Dockerspec
  module Serverspec
    #
    # A class to handle the underlying Specinfra backend.
    #
    # This class saves Specinfra instance in internally and then it is able
    # to recover it from there and setup the running environment accordingly.
    #
    # This class uses a small hack in the Specinfra class to reset its internal
    # singleton instance.
    #
    class SpecinfraBackend
      #
      # The SpecinfraBackend constructor.
      #
      # @param backend [Symbol, Specinfra::Backend::Base, Class] The backend
      #   can be the backend name as a symbol, a Specinfra backend object or
      #   a Specinfra backend class.
      #
      # @api public
      #
      def initialize(backend)
        @backend = backend
      end

      #
      # Saves the Specinfra backend instance reference internally.
      #
      # @return void
      #
      # @api public
      #
      def save
        @saved_backend_instance = backend_instance
      end

      #
      # Restores the Specinfra backend instance.
      #
      # @return void
      #
      # @api public
      #
      def restore
        instance_set(@saved_backend_instance)
      end

      #
      # Resets the Specinfra backend.
      #
      # @return void
      #
      # @api public
      #
      def reset
        instance_set(nil)
      end

      protected

      #
      # Sets the Specinfra backend.
      #
      # Used by {.load}.
      #
      # @param instance [Specinfra::Backend::Base] The Specinfra backend
      #   object.
      #
      # @return void
      #
      # @api private
      #
      def instance_set(instance)
        backend_class.instance_set(instance)
      end

      #
      # Returns the current Specinfra backend object.
      #
      # @return [Specinfra::Backend::Base] The Specinfra backend object.
      #
      # @api private
      #
      def backend_instance
        backend_class.instance
      end

      #
      # Returns the current Specinfra backend class.
      #
      # @return [Class] The Specinfra backend class.
      #
      # @api private
      #
      def backend_class
        @backend_class ||= begin
          if Class == @backend.class && @backend <= Specinfra::Backend::Base
            return @backend
          end
          return @backend.class if @backend.is_a?(Specinfra::Backend::Base)
          Specinfra::Backend.const_get("#{@backend.to_s.to_camel_case}")
        end
      end
    end
  end
end
