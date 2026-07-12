module ActiveInteraction::Extras::FileBlobs
  extend ActiveSupport::Concern

  # Returns the blobs for a given array field.
  #
  # @example has_one_attached :file
  #
  #   # doc/_form.html.slim
  #   = f.hidden_field :file, value: nil
  #
  #   - form.blobs_for(:file).each do |blob|
  #     div data-controller="remove"
  #       = f.hidden_field :file, value: blob.signed_id
  #       - if blob.representable?
  #         = image_tag url_for(blob.representation(resize_to_fit: [300, 80])), height: 80
  #       button type="button" data-action="click->remove#remove"
  #         'Remove
  #
  #   = f.input :new_file, as: :file
  #
  #   # doc/form.rb
  #   class Doc::Form < ActiveInteraction::Base
  #     object :doc
  #
  #     model_fields(:doc) do
  #       anything :file
  #     end
  #
  #     anything :new_file, permit: true, default: nil
  #
  #     def execute
  #       save_model!(:doc)
  #
  #       if inputs.given?(:new_file)
  #         doc.file = new_file
  #         doc.save!
  #       end
  #     end
  #   end
  #
  # @example has_many_attached :files
  #
  #   # doc/_form.html.slim
  #   = f.file_field :files, multiple: true, direct_upload: true
  #
  #   # doc/form.rb
  #   class Doc::Form < ActiveInteraction::Base
  #     object :doc
  #
  #     model_fields(:doc) do
  #       array :files
  #     end
  #
  #     def execute
  #       save_model!(:files)
  #     end
  #   end
  #
  def blobs_for(array_field)
    # If there is a new upload field, prioritize it
    new_upload = "new_#{array_field}"
    if respond_to?(new_upload) && public_send(new_upload).present?
      array_field = new_upload
    end

    list = public_send(array_field)
    list = Array.wrap(list)

    list.compact_blank.map do |file|
      case file
      when ActiveStorage::Blob
        file
      when ActiveStorage::Attachment, ActiveStorage::Attached::One
        file.blob
      when String
        ActiveStorage::Blob.find_signed(file)
      end
    end.compact
  end
end
