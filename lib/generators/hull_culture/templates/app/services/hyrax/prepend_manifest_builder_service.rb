# frozen_string_literal: true
module Hyrax
  module PrependManifestBuilderService
    attr_accessor :presenter, :request

    # Override Hyrax 2.9.3 - append media sequences for Multi Media manifest 
    # type can be blank for all qualifying formats or one of audio, video, pdf
    #
    def manifest_for(presenter:, manifest_type: '')
      @manifest_type = manifest_type
      @presenter = presenter
      # Do we do this at all if we have requested a "normal" manifest (i.e. manifest_type=image)
      # Or do we get a bit more filtery at the next stage (e.g. if there are any images avoid mediaSequences?)
      add_media_sequences_for_pdf(sanitized_manifest(presenter: presenter))
    end

    # Return resolvable base_url + path
    # Requires that default_url_options host, port, etc are properly set
    #
    def hyrax_url(path)
      URI.join(Rails.application.routes.url_helpers.root_url,path).to_s
    end

    # The following are all Additional methods to Hyrax::ManifestBuilderService 2.9.3
    # They are for the purpose of building mediaSequences to allow the presentation of pdf, audio, video etc in UV
    # They (along with this prepend) will all be defunct once Hyrax switch to using IIIF 3.0 
    # https://iiif.io/api/presentation/3.0/#32-technical-properties
    #
    # Amended to respond to traditional request to concern/[model]/:id/manifest, but also 
    # manifest_mm/:id/:manifest_type (allowing us to request a manifest of a given format (e.g. audio)
    #
    def add_media_sequences_for_pdf(manifest)
      # If we have mixed media that includes images it might be prudent to 
      # present a trad. image manifest without mediaSequence
      images = @presenter.file_set_presenters.select{ |f| f.image? }

      if @manifest_type.blank?
        # No manifest type requested, gather all the qualifying files (apart from images)
        other_files = @presenter.file_set_presenters.select{ |f| f.pdf? || f.audio? || f.video? }
      else
        # Gather the files that have been requested #TODO error catching for non-qualifying file types
        other_files = @presenter.file_set_presenters.select{ |f| f.send "#{@manifest_type}?" }
      end
      #If we are not asking for images or there are no images present but we do have qualifying files we add mediaSequnce 
      if (other_files.present? and not images.present? and @manifest_type != 'image')
        manifest['@context'] = [manifest['@context'], 'https://wellcomelibrary.org/ld/ixif/0/context.json']
        manifest['mediaSequences'] = [media_sequences(other_files, manifest['sequences'])]
        # If we are adding media sequences there's not much point in keeping the old sequnces as far as I can see
        # If we do wan them switch the following two lines
        #manifest['sequences'] ||= []
        manifest['sequences'] = []
        manifest['sequences'] += [add_placeholder_sequence]
      end
      manifest
    end 

    def media_type(file)
       mt = "unknown:Thing"
       mt = "dctypes:Sound" if file.audio?
       mt = "foaf:Document" if file.pdf?
       mt = "dctypes:MovingImage" if file.video?
       mt
    end

    def media_sequences(files, sequences)
      elements = files.map do |f|
        media_sequence(
          file_url(f.id, false),
          file_url(f.id, true),
          f.title.first.to_s,
          file_metadata(f),
          f.mime_type,
          media_type(f),
          file_rendering(f)
        )
      end
      # add sequences (i.e. images to the media sequence)
      # Do we want to do this? It makes for a not-as-good user ex for images I think
      # In this case (Hull Culture) we present via aother blacklight so no
#      unless sequences.blank?
#        sequences.first['canvases'].each do |canvas|
#          elements << media_sequence(
#            canvas['images'].first['resource']['@id'],
#            image_thumb(canvas['images'].first['resource']['@id']),
#            canvas['label'],
#            [{ 'height': canvas['width'], 'width': canvas['width'] }],
#            '',
#            canvas['images'].first['resource']['@type'],
#            '',
#          )
#        end
#      end
      {
        "@id": hyrax_url("/iiif/#{@presenter.id}/xsequence/s0"),
        "@type": "ixif:MediaSequence",
        "label": "XSequence #{@presenter.id}",
        "elements": elements
      }
    end

    def media_sequence(url, thumbnail, label, metadata, format, type, rendering)
      {
        "@id": url,
        "@type": type,
        "format": format,
        "label": label,
        "metadata": metadata,
        "thumbnail": thumbnail,
        "rendering": rendering
      }
    end
    
    def file_rendering(file)
      {
        "@id": file_url(file.id),
        "format": file.mime_type
      }
    end

    def add_placeholder_sequence()
      {
        "@id": hyrax_url("/iiif/ixif-message/sequence/seq"),
        "@type": "sc:Sequence",
        "label": "Unsupported extension. This manifest is being used as a wrapper for non-IIIF content (e.g., audio, video) and is unfortunately incompatible with IIIF viewers.",
        "compatibilityHint": "displayIfContentUnsupported",
        "canvases": [
          {
            "@id": hyrax_url("/iiif/ixif-message/canvas/c1"),
            "@type": "sc:Canvas",
            "label": "Placeholder image",
            # @TODO changethis
            "thumbnail": hyrax_url("/placeholder.jpg"),
            "height": 600,
            "width": 600,
            "images": [
              {
                "@id": hyrax_url("/iiif/ixif-message/imageanno/placeholder"),
                "@type": "oa:Annotation",
                "motivation": "sc:painting",
                "resource": {
                  "@id": hyrax_url("/iiif/ixif-message-0/res/placeholder"),
                  "@type": "dctypes:Image",
                  "height": 600,
                  "width": 600
                },
                "on": hyrax_url("/iiif/ixif-message/canvas/c1")
              }
            ]
          }
        ]
      }
    end

    def file_url(id, thumb = false)
      if thumb
        # TODO make this resolve to a duitable icon if no thumbnail available
        hyrax_url("/downloads/#{id}?file=thumbnail")
      else
        hyrax_url("/manifest_file/#{id}")
      end
    end

    def image_thumb(url)
      url.split('/full/full').join('/full/90,')
    end

    def file_metadata(file)
      md = [
       {
        "label": "title",
        "value": @presenter.title.first.to_s
       } 
      ]
      if file.pdf?
       md.push (
         {
          "label": "pages",
          "value": file.page_count.blank? ? '' : file.page_count.first.to_s
         }
       )
      end
      if file.audio? || file.video?
       md.push (
         {
          "label": "length",
          "value": file.duration[0]
         }
       )
      end
      md
    end

  end
end
