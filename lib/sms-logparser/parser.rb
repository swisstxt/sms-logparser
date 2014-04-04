module SmsLogparser
  class Parser

    def self.extract_data_from_msg(message)
      if self.match?(message)
        m = message.match /\/content\/(\d+)\/(\d+)\/(\d+)\/(\w+\.\w+)\s.*\"\s\d+\s(\d+).+"(.*)"$/
        raise "No match found." unless m
        traffic_type = Parser.get_traffic_type(m[6])
        visitor_type = Parser.get_visitor_type(traffic_type, m[4])
        return {
          :customer_id => m[1],
          :author_id => m[2],
          :project_id => m[3],
          :file =>  m[4],
          :bytes => m[5],
          :user_agent => m[6],
          :traffic_type => traffic_type,
          :visitor_type => visitor_type
        }
      end
      nil
    end

    def self.match?(message)
      match = message.match(
        /\/content\/.+\/(\w+\.(f4v|flv|mp4|mp3|ts|m3u8)) .+ (200|206)/i
      )
      if match
        return true unless match[1] =~ /detect.mp4|index.m3u8/i
      end
      false
    end

    # see https://developer.mozilla.org/en-US/docs/Browser_detection_using_the_user_agent
    # for mobile browser detection
    def self.get_traffic_type(user_agent)
      case user_agent
      when /.*(iTunes).*/
        "TRAFFIC_PODCAST"
      when /.*(Mobi|IEMobile|Mobile Safari|iPhone|iPod|iPad|Android|BlackBerry|Opera Mini).*/
        "TRAFFIC_MOBILE"
      else
        "TRAFFIC_WEBCAST"
      end
    end

    def self.get_visitor_type(traffic_type, file)
      return "VISITORS_MOBILE" if file == 'index.m3u8'
      case traffic_type
      when "TRAFFIC_PODCAST"
        "VISITORS_PODCAST"
      when "TRAFFIC_MOBILE"
        if File.extname(file) != ".ts"
          "VISITORS_MOBILE"
        else
          nil
        end
      else
        "VISITORS_WEBCAST"
      end
    end

  end # class
end # module