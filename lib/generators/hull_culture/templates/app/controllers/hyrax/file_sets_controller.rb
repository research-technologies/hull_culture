module Hyrax
  class FileSetsController < ApplicationController

    # change these lines to include manifest_file
    before_action :authenticate_user!, except: [:show, :citation, :stats, :manifest_file]
    load_and_authorize_resource class: ::FileSet, except: [:show, :manifest_file]

    # add manifest_file method
    # Override Hyrax 2.5.1 - add route for manifest pdf
    # GET /manifest_file/:id
    def manifest_file
      file = ::FileSet.find(params[:id]).original_file
      raise Hyrax::ObjectNotFoundError unless file.is_a?(ActiveFedora::File)
      self.status = 200
      response.headers['Content-Type'] = file.mime_type
      response.headers['Content-Length'] = file.size.to_s
      response.headers['Access-Control-Allow-Origin'] = '*'
      self.response_body = file.stream
    end

  end
end
