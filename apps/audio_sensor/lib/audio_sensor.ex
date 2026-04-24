defmodule AudioSensor do
  @modelo_default "openai/whisper-tiny"

  def init(opts \\ []) do
    modelo = Keyword.get(opts, :modelo, @modelo_default)
    
    {:ok, whisper} = Bumblebee.load_model({:hf, modelo})
    {:ok, featurizer} = Bumblebee.load_featurizer({:hf, modelo})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, modelo})
    {:ok, generation_config} = Bumblebee.load_generation_config({:hf, modelo})

    Bumblebee.Audio.speech_to_text(
      whisper,
      featurizer,
      tokenizer,
      generation_config,
      compile: [batch_size: 1]
      # ELIMINADO para Windows: defn_options: [compiler: EXLA]
    )
  end

  def transcribir(serving, ruta_archivo) do
    resultado = Nx.Serving.run(serving, {:file, ruta_archivo})

    resultado.results
    |> Enum.map(& &1.text)
    |> Enum.join(" ")
    |> String.trim()
  end
end
