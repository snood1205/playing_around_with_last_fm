Rails.application.routes.draw do
  resource :tracks, except: :show do
    attributes = %w[artist name album]
    (1..attributes.size).each do |size|
      attributes.permutation(size).each do |attrs|
        get :"by_#{attrs.join '_and_'}"
      end
    end
  end
end
