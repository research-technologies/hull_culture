
module Hyrax
  module VisibilityControllerBehavior
    extend ActiveSupport::Concern
    
    included do 
      # allow requests through, we'll authenticate and check the values
      protect_from_forgery except: :change_visibility
    end
    
    class_methods do
      # override - add visibility urls
      def curation_concern_type=(curation_concern_type)
        load_and_authorize_resource class: curation_concern_type, instance_name: :curation_concern, except: [:show, :file_manager, :inspect_work, :manifest, :visibility, :update_visibility]

        # Load the fedora resource to get the etag.
        # No need to authorize for the file manager, because it does authorization via the presenter.
        load_resource class: curation_concern_type, instance_name: :curation_concern, only: :file_manager

        self._curation_concern_type = curation_concern_type
        # We don't want the breadcrumb action to occur until after the concern has
        # been loaded and authorized
        before_action :save_permissions, only: :update
      end
      
    end

    # GET return the visibility
    def visibility
      @curation_concern = _curation_concern_type.find(params[:id]) unless curation_concern
      json = { curation_concern.id => { visibility: curation_concern.visibility, members: [] } }
      curation_concern.members.each do | m | 
        json[curation_concern.id][:members] << { m.id => { visibility: m.visibility } }
      end
      respond_to do |wants|
          wants.json {
            render json: json.to_json
          }
      end
    end
    
    # POST update the visibibility
    # Required parameters in post body (DO NOT USE URL parameters - this will contain the password)
    #   email: email for the admin user requesting the change
    #   password: password for the admin user requesting the change
    #   visibility: 'open', 'restricted' or 'private'
    #   cascade: 'true' or 'false'
    def update_visibility
      respond_to do |wants|
        wants.json {
          user = ::User.find_for_authentication(:email => params['email'])
          
          if !user.nil? && user.valid_password?(params['password']) && user.admin?
            json, status = change_visibility_from_params
            render json: json.to_json, status: status
          else
            render json: { error: 'unauthorized' }.to_json, status: :unauthorized
          end
        }
      end
    end
    
    private
    
    def change_visibility_from_params
      if params['visibility'] && reject_visibility?
        return { status: 'unprocessable', message: 'invalid visibility, must be one of open, authenticated or restricted' }, :unprocessable_entity
      elsif params['visibility'] && params['cascade']
        change_visibility
      else
        return { status: 'unprocessable', message: 'missing parameters'}, :unprocessable_entity
      end
    end
    
    def change_visibility
      @curation_concern = _curation_concern_type.find(params[:id]) unless curation_concern
      case
      # If there is an embargo, leave it
      when (!curation_concern.embargo.nil? && curation_concern.embargo.embargo_release_date > Time.now)
        return { status: 'embargoed', message: "#{curation_concern.id} is under embargo until #{curation_concern.embargo.embargo_release_date}. " }, :ok
      # if there is a lease, leave it
      when (!curation_concern.lease.nil? && curation_concern.lease.lease_release_date > Time.now )
        return { status: 'leased', message: "#{curation_concern.id} is under a lease until #{curation_concern.lease.lease_release_date}. " }, :ok
      # if the visibility is already set to the same as the param
      when curation_concern.visibility == params['visibility'] 
        return { status: 'unchanged', message: "#{curation_concern.id} already has the visibility of #{curation_concern.visibility}" }, :ok
      # Otherwise change the visibility
      else
        change_concern_visibility
        return { status: 'changed', message: "#{curation_concern.id} was changed to #{curation_concern.visibility}. #{members}" }, :ok
      end
    end
    
    def check_restrictions
      
    end
    
    def members
      if params['cascade']== 'true'
        "Members were updated."
      else
        "Members were not updated."
      end
    end
    
    def change_concern_visibility
      curation_concern.visibility = params['visibility']
      change_member_visibility if params['cascade'] == 'true'
      saved = curation_concern.save
      raise StandardError(curation_concerns.errors.messages) if saved == false
      rescue StandardError => e
        return { status: 'error', message: e.message }, :internal_server_error
    end
    
    def change_member_visibility
      curation_concern.file_sets.each do | fs |
        fs.visibility = params['visibility'] unless fs.visibility == params['visibility']
        fs.save
      end
    end
    
    def reject_visibility?
      return true unless ['open', 'restricted', 'authenticated'].include? params['visibility']
    end
    
  end
end