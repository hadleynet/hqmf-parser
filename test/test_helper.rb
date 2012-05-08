require 'cover_me'
require 'bundler/setup'
require 'test/unit'
require 'turn'

# Load project files
PROJECT_ROOT = File.expand_path("../../", __FILE__)
require_relative File.join(PROJECT_ROOT, 'lib', 'hqmf-parser')

class Hash
  def diff_hash(other)
    (self.keys | other.keys).inject({}) do |diff, k|
      left = self[k]
      right = other[k]
      unless left == right
        if left.is_a? Hash
          tmp = left.diff_hash(right)
          diff[k] = tmp unless tmp.empty?
        else
          diff[k] = "EXPECTED: #{left}, FOUND: #{right}"
        end
      end
      diff
    end
  end
end

