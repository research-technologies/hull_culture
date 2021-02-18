# frozen_string_literal: true
module Hyrax
  module PrependWorksControllerBehavior
    # Override Hyrax 2.5.1 - append media sequences for PDF
    def manifest
      headers['Access-Control-Allow-Origin'] = '*'
      # Override Hyrax 2.5.1 - move hash conversion into manifest_builder
      json = sanitize_manifest(JSON.parse(cached_manifest))

      respond_to do |wants|
        wants.json { render json: json }
        wants.html { render json: json }
      end
    end

    # Override Hyrax 2.5.1 - additional method
    # Cache the manifest, delete from cache if date_modified is today
    def cached_manifest
      Rails.cache.delete("manifest/#{presenter.id}") if DateTime.strptime(presenter.date_modified, '%m/%d/%Y') == Date.today
      Rails.cache.fetch("manifest/#{presenter.id}") do
        manifest_builder.to_json
      end
    end

    # Override Hyrax 2.5.1 - append media sequences for PDF
    def manifest_builder
      mf = ::IIIFManifest::ManifestFactory.new(presenter).to_h
      add_media_sequences_for_pdf(mf)
    end

    # Override Hyrax 2.5.1 - additional method
    # Adds non-IIIF compliant mediaSequences section for PDFs.
    # @see https://gist.github.com/tomcrane/7f86ac08d3b009c8af7c
    # "mediaSequences": [
    #   {
    #     "@id": "https://wellcomelibrary.org/iiif/b17502792/xsequence/s0",
    #     "@type": "ixif:MediaSequence",
    #     "label": "XSequence 0",
    #     "elements": [
    #       {
    #         "@id": "https://dlcs.io/file/wellcome/1/caf18956-8f79-4fe6-8988-af329b036416",
    #         "@type": "foaf:Document",
    #         "format": "application/pdf",
    #         "label": "Science and the public : a review of science communication and public attitudes to science in Britain : a joint report",
    #         "metadata": [
    #           {
    #             "label": "pages",
    #             "value": "137"
    #           }
    #         ],
    #         "thumbnail": "https://wellcomelibrary.org/pdfthumbs/b17502792/0/caf18956-8f79-4fe6-8988-af329b036416.jpg"
    #       }
    #     ]
    #   }
    # ],
    def add_media_sequences_for_pdf(manifest)
      pdfs = presenter.file_set_presenters.select(&:pdf?)
      if pdfs.present?
        manifest['@context'] = [manifest['@context'], 'https://wellcomelibrary.org/ld/ixif/0/context.json']
        manifest['mediaSequences'] = [media_sequences(presenter, pdfs, manifest['sequences'])]
        manifest['sequences'] ||= []
        manifest['sequences'] += [add_placeholder_sequence]
      end
      manifest
    end

    # Override Hyrax 2.5.1 - additional method
    def media_sequences(work, pdfs, sequences)
      elements = pdfs.map do |p|
        media_sequence(
          pdf_url(p.id),
          pdf_url(p.id, true),
          p.title.first.to_s,
          pdf_metadata(p,work),
          "application/pdf",
          "foaf:Document"
        )
      end
      # add sequences
      unless sequences.blank?
        sequences.first['canvases'].each do |canvas|
          elements << media_sequence(
            canvas['images'].first['resource']['@id'],
            image_thumb(canvas['images'].first['resource']['@id']),
            canvas['label'],
            [{ 'height': canvas['width'], 'width': canvas['width'] }],
            '',
            canvas['images'].first['resource']['@type']
          )
        end
      end

      {
        "@id": "#{request.base_url}/iiif/#{work.id}/xsequence/s0",
        "@type": "ixif:MediaSequence",
        "label": "XSequence #{work.id}",
        "elements": elements
      }
    end

    # Override Hyrax 2.5.1 - additional method
    def media_sequence(url, thumbnail, label, metadata, format, type)
      {
        "@id": url,
        "@type": type,
        "format": format,
        "label": label,
        "metadata": metadata,
        "thumbnail": thumbnail
      }
    end

    # Override Hyrax 2.5.1 - additional method
    def add_placeholder_sequence
      {
        "@id": "#{request.base_url}/iiif/ixif-message/sequence/seq",
        "@type": "sc:Sequence",
        "label": "Unsupported extension. This manifest is being used as a wrapper for non-IIIF content (e.g., audio, video) and is unfortunately incompatible with IIIF viewers.",
        "compatibilityHint": "displayIfContentUnsupported",
        "canvases": [
          {
            "@id": "#{request.base_url}/iiif/ixif-message/canvas/c1",
            "@type": "sc:Canvas",
            "label": "Placeholder image",
            # @todo changethis
            "thumbnail": "#{request.base_url}/placeholder.jpg",
            "height": 600,
            "width": 600,
            "images": [
              {
                "@id": "#{request.base_url}/iiif/ixif-message/imageanno/placeholder",
                "@type": "oa:Annotation",
                "motivation": "sc:painting",
                "resource": {
                  "@id": "#{request.base_url}/iiif/ixif-message-0/res/placeholder",
                  "@type": "dctypes:Image",
                  "height": 600,
                  "width": 600
                },
                "on": "#{request.base_url}/iiif/ixif-message/canvas/c1"
              }
            ]
          }
        ]
      }
    end

    # Override Hyrax 2.5.1 - additional method
    def pdf_url(id, thumb = false)
      if thumb
        "#{request.base_url}/downloads/#{id}?file=thumbnail"
      else
        "#{request.base_url}/manifest_file/#{id}"
      end
    end

    # Override Hyrax 2.5.1 - additional method
    def image_thumb(url)
      url.split('/full/full').join('/full/90,')
    end

    # Override Hyrax 2.5.1 - additional method
    def pdf_metadata(pdf,parent_work)
      [
        "label": "pages",
        "value": pdf.page_count.blank? ? '' : pdf.page_count.first.to_s
      ]
    end

    # Override Hyrax 2.5.1 - taken from Hyrax master
    #   remove on upgrade after 2.5.1
    def sanitize_manifest(hash)
      hash['label'] = sanitize_value(hash['label']) if hash.key?('label')
      hash['description'] = hash['description']&.collect { |elem| sanitize_value(elem) } if hash.key?('description')

      hash['sequences']&.each do |sequence|
        sequence['canvases']&.each do |canvas|
          canvas['label'] = sanitize_value(canvas['label'])
        end
      end
      hash
    end

    # Override Hyrax 2.5.1 - taken from Hyrax master
    #   remove on upgrade after 2.5.1
    def sanitize_value(text)
      Loofah.fragment(text.to_s).scrub!(:prune).to_s
    end
  end
end
