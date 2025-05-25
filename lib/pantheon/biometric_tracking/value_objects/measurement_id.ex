defmodule Pantheon.BiometricTracking.ValueObjects.MeasurementId do
  @moduledoc """
  Unique identifier for a biometric measurement with external source tracking.

  A MeasurementId represents a unique identifier for a specific biometric measurement
  record. It uses UUID v4 for the primary identifier to ensure global uniqueness,
  while tracking external source information for integration and deduplication purposes.

  ## External Source Tracking

  The MeasurementId can track measurements from external sources:
  - `external_source`: The system/device that provided the measurement
  - `external_id`: The original identifier from the external system

  This enables proper deduplication and audit trails for imported data.

  ## Examples

      # Internal measurement (system-generated)
      iex> id = MeasurementId.new()
      iex> id.external_source
      nil

      # External measurement with known source
      iex> {:ok, id} = MeasurementId.new_external("apple_health", "HK-12345-weight")
      iex> id.external_source
      "apple_health"

      # External measurement with unknown source
      iex> {:ok, id} = MeasurementId.new_external(nil, "unknown-device-001")
      iex> id.external_source
      "unspecified"
  """

  @type external_source :: String.t() | nil
  @type external_id :: String.t() | nil

  @type t :: %__MODULE__{
    value: String.t(),
    external_source: external_source(),
    external_id: external_id()
  }

  defstruct [:value, :external_source, :external_id]

  # Known external sources - can be extended as we integrate more systems
  @valid_external_sources [
    "apple_health",
    "google_fit",
    "fitbit",
    "garmin",
    "withings",
    "omron_scale",
    "tanita_scale",
    "manual_entry",
    "clinician_entry",
    "unspecified"
  ]

  @doc """
  Creates a new internal MeasurementId with a randomly generated UUID v4.

  Internal measurements are those created directly by our system.
  """
  @spec new() :: t()
  def new do
    %__MODULE__{
      value: UUID.uuid4(),
      external_source: nil,
      external_id: nil
    }
  end

  @doc """
  Creates a MeasurementId from an existing UUID string for internal use.

  Validates that the provided string is a valid UUID format.
  """
  @spec from_uuid(String.t()) :: {:ok, t()} | {:error, :invalid_uuid}
  def from_uuid(uuid_string) when is_binary(uuid_string) do
    case UUID.info(uuid_string) do
      {:ok, _info} ->
        {:ok, %__MODULE__{
          value: uuid_string,
          external_source: nil,
          external_id: nil
        }}
      {:error, _} ->
        {:error, :invalid_uuid}
    end
  end

  def from_uuid(_), do: {:error, :invalid_uuid}

  @doc """
  Creates a new MeasurementId for an external measurement.

  Generates a new UUID while preserving external source information
  for deduplication and audit purposes.

  ## Parameters

    - `external_source` - Source system identifier (nil for unknown)
    - `external_id` - Original identifier from external system

  ## Returns

    - `{:ok, %MeasurementId{}}` - Success with the created measurement ID
    - `{:error, :invalid_external_source}` - If external_source is invalid
    - `{:error, :invalid_external_id}` - If external_id is invalid

  ## Examples

      iex> MeasurementId.new_external("apple_health", "HK-12345-weight")
      {:ok, %MeasurementId{external_source: "apple_health", external_id: "HK-12345-weight"}}

      iex> MeasurementId.new_external(nil, "unknown-device-001")
      {:ok, %MeasurementId{external_source: "unspecified", external_id: "unknown-device-001"}}
  """
  @spec new_external(String.t() | nil, String.t()) :: {:ok, t()} | {:error, atom()}
  def new_external(external_source, external_id) do
    with {:ok, validated_source} <- validate_external_source(external_source),
         {:ok, validated_id} <- validate_external_id(external_id) do
      {:ok, %__MODULE__{
        value: UUID.uuid4(),
        external_source: validated_source,
        external_id: validated_id
      }}
    end
  end

  @doc """
  Creates a MeasurementId from complete external information including UUID.

  Used when reconstructing from events or when the UUID is already known.
  """
  @spec from_external(String.t(), String.t() | nil, String.t()) :: {:ok, t()} | {:error, atom()}
  def from_external(uuid_string, external_source, external_id) do
    with {:ok, _} <- UUID.info(uuid_string),
         {:ok, validated_source} <- validate_external_source(external_source),
         {:ok, validated_id} <- validate_external_id(external_id) do
      {:ok, %__MODULE__{
        value: uuid_string,
        external_source: validated_source,
        external_id: validated_id
      }}
    else
      {:error, :invalid_external_source} = error -> error
      {:error, :invalid_external_id} = error -> error
      {:error, _} -> {:error, :invalid_uuid}
    end
  end

  @doc """
  Checks if this measurement came from an external source.
  """
  @spec external?(t()) :: boolean()
  def external?(%__MODULE__{external_source: nil}), do: false
  def external?(%__MODULE__{external_source: _}), do: true

  @doc """
  Returns the external reference for deduplication purposes.

  Returns a tuple that can be used to identify duplicate measurements
  from the same external source.
  """
  @spec external_reference(t()) :: {String.t(), String.t()} | nil
  def external_reference(%__MODULE__{external_source: nil}), do: nil
  def external_reference(%__MODULE__{external_source: source, external_id: id}), do: {source, id}

  @doc """
  Lists all valid external source identifiers.
  """
  @spec valid_external_sources() :: [String.t()]
  def valid_external_sources, do: @valid_external_sources

  # Private validation functions

  @spec validate_external_source(String.t() | nil) :: {:ok, String.t()} | {:error, :invalid_external_source}
  defp validate_external_source(nil), do: {:ok, "unspecified"}
  defp validate_external_source(source) when is_binary(source) do
    trimmed = String.trim(source)
    cond do
      trimmed in @valid_external_sources -> {:ok, trimmed}
      String.length(trimmed) == 0 -> {:ok, "unspecified"}
      true -> {:error, :invalid_external_source}
    end
  end
  defp validate_external_source(_), do: {:error, :invalid_external_source}

  @spec validate_external_id(String.t()) :: {:ok, String.t()} | {:error, :invalid_external_id}
  defp validate_external_id(external_id) when is_binary(external_id) do
    trimmed = String.trim(external_id)
    case String.length(trimmed) do
      0 -> {:error, :invalid_external_id}
      _ -> {:ok, external_id}  # Keep original formatting
    end
  end
  defp validate_external_id(_), do: {:error, :invalid_external_id}
end
