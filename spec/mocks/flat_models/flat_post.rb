class FlatPost < Flatten::Document
  alternate_id :permalink

  property :title, :body, :category_ids

  embed :blog do
    property :name
  end

  embed_collection :comments do
    property :text
  end
end
