# frozen_string_literal: true
module Hyrax
  module PrependManifestBuilderService
    attr_accessor :presenter, :request

    # Override Hyrax 2.9.3 - append media sequences for PDF 
    #
    def manifest_for(presenter:)
      @presenter = presenter
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
    def add_media_sequences_for_pdf(manifest)
      pdfs = @presenter.file_set_presenters.select(&:pdf?)
      if pdfs.present?
        manifest['@context'] = [manifest['@context'], 'https://wellcomelibrary.org/ld/ixif/0/context.json']
        manifest['mediaSequences'] = [media_sequences(pdfs, manifest['sequences'])]
        manifest['sequences'] ||= []
        manifest['sequences'] += [add_placeholder_sequence]
      end
      manifest
    end

    def media_sequences(pdfs, sequences)
      elements = pdfs.map do |p|
        media_sequence(
          pdf_url(p.id, false),
          pdf_url(p.id, true),
          p.title.first.to_s,
          pdf_metadata(p),
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
        "@id": hyrax_url("/iiif/#{@presenter.id}/xsequence/s0"),
        "@type": "ixif:MediaSequence",
        "label": "XSequence #{@presenter.id}",
        "elements": elements
      }
    end

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
            # @todo changethis
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

    def pdf_url(id, thumb = false)
      if thumb
        hyrax_url("/downloads/#{id}?file=thumbnail")
      else
        hyrax_url("/manifest_file/#{id}")
      end
    end

    def image_thumb(url)
      url.split('/full/full').join('/full/90,')
    end

    def pdf_metadata(pdf)
      [
       {
        "label": "pages",
        "value": pdf.page_count.blank? ? '' : pdf.page_count.first.to_s
       },
       {
        "label": "biblionumber",
        "value": @presenter.biblionumber.first.to_s
       },
       {
        "label": "title",
        "value": @presenter.title.first.to_s
       } 
      ]
    end

  end
end
