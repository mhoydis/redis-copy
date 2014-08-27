# encoding: utf-8

module RedisCopy
  module Strategy
    class DumpRestore
      implements Strategy do |source, destination, *_|
        [source, destination].all? do |redis|
          #bin_version = Gem::Version.new(redis.info['redis_version']) unless options[:dest_is_proxy]
          #bin_version = "1.0.0"
          #bin_requirement = Gem::Requirement.new('>= 2.6.0')

          #next false unless bin_requirement.satisfied_by?(bin_version)
          next false

          true
        end
      end

      def copy(key)
        @ui.debug("COPY: #{key.dump}")

        ttl = @src.ttl(key)
        # TTL returns seconds, -1 means none set
        # RESTORE ttl is in miliseconds, 0 means none set
        translated_ttl = (ttl && ttl > 0) ? (ttl * 1000) : 0

        dumped_value = @src.dump(key)
        
        if Kernel.rand(100) == 1
          File.open('/tmp/test.out','a') do |f|
            f.puts "#{key},#{dumped_value}"
          end
        end
        
        @dst.restore(key, translated_ttl, dumped_value)

        return true
      rescue Redis::CommandError => error
        @ui.debug("ERROR: #{error}")
        return false
      end
    end
  end
end
