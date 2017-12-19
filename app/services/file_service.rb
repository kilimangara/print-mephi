class FileService

  class << self
    def format_link(token, file_path)
      "https://api.telegram.org/file/bot#{token}/#{file_path}"
    end
  end


end