defmodule VisionSensor do
  @modelo_default "microsoft/resnet-50"

  def init(opts \\ []) do
    modelo = Keyword.get(opts, :modelo, @modelo_default)
    
    {:ok, resnet} = Bumblebee.load_model({:hf, modelo})
    {:ok, featurizer} = Bumblebee.load_featurizer({:hf, modelo})

    Bumblebee.Vision.image_classification(resnet, featurizer,
      top_k: 5,
      compile: [batch_size: 1]
      # ELIMINADO para Windows: defn_options: [compiler: EXLA]
    )
  end

  def clasificar(serving, ruta_image) do
    # Nota: Usamos StbImage para cargar la imagen
    imagen = 
      ruta_image
      |> File.read!()
      |> StbImage.read_binary!()

    resultado = Nx.Serving.run(serving, imagen)

    resultado.predictions
    |> Enum.map(fn pred -> 
      %{label: pred.label, score: Float.round(pred.score, 4)} 
    end)
  end
end
