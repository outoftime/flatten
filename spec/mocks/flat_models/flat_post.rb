class FlatPost < Flatten::Document
  alternate_id :permalink

  property :title, :body, :category_ids

  embed :blog do
    property :name
  end

  embed_collection :comments do
    property :text
    scope(:with_text) { |comments| comments.select { |comment| comment.text }}
  end

  embed_collection :photos, :using => FlatPhoto
  embed :featured_photo, :using => FlatPhoto
end
