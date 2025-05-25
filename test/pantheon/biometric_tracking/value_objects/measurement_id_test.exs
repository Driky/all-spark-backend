defmodule Pantheon.BiometricTracking.ValueObjects.MeasurementIdTest do
  use ExUnit.Case, async: true

  alias Pantheon.BiometricTracking.ValueObjects.MeasurementId

  describe "new/0 - internal measurements" do
    test "creates a new measurement ID with UUID value and no external info" do
      id = MeasurementId.new()

      assert %MeasurementId{value: value, external_source: nil, external_id: nil} = id
      assert is_binary(value)
      assert String.length(value) == 36 # Standard UUID length
      assert String.match?(value, ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
    end

    test "creates unique IDs on successive calls" do
      id1 = MeasurementId.new()
      id2 = MeasurementId.new()

      assert id1.value != id2.value
      assert id1.external_source == nil
      assert id2.external_source == nil
    end
  end

  describe "from_uuid/1 - internal measurements from existing UUID" do
    test "creates measurement ID from valid UUID string" do
      uuid_string = "123e4567-e89b-12d3-a456-426614174000"

      assert {:ok, %MeasurementId{
        value: ^uuid_string,
        external_source: nil,
        external_id: nil
      }} = MeasurementId.from_uuid(uuid_string)
    end

    test "rejects invalid UUID formats" do
      assert {:error, :invalid_uuid} = MeasurementId.from_uuid("not-a-uuid")
      assert {:error, :invalid_uuid} = MeasurementId.from_uuid("123-456-789")
      assert {:error, :invalid_uuid} = MeasurementId.from_uuid("")
    end

    test "rejects non-string values" do
      assert {:error, :invalid_uuid} = MeasurementId.from_uuid(123)
      assert {:error, :invalid_uuid} = MeasurementId.from_uuid(nil)
      assert {:error, :invalid_uuid} = MeasurementId.from_uuid(:atom)
    end
  end

  describe "new_external/2 - external measurements" do
    test "creates external measurement with known source" do
      assert {:ok, %MeasurementId{
        external_source: "apple_health",
        external_id: "HK-12345-weight"
      } = id} = MeasurementId.new_external("apple_health", "HK-12345-weight")

      assert is_binary(id.value)
      assert String.length(id.value) == 36
    end

    test "creates external measurement with unspecified source when nil provided" do
      assert {:ok, %MeasurementId{
        external_source: "unspecified",
        external_id: "unknown-device-001"
      }} = MeasurementId.new_external(nil, "unknown-device-001")
    end

    test "creates external measurement with unspecified source when empty string provided" do
      assert {:ok, %MeasurementId{
        external_source: "unspecified",
        external_id: "device-123"
      }} = MeasurementId.new_external("", "device-123")
    end

    test "accepts all valid external sources" do
      valid_sources = [
        "apple_health", "google_fit", "fitbit", "garmin", "withings",
        "omron_scale", "tanita_scale", "manual_entry", "clinician_entry"
      ]

      for source <- valid_sources do
        assert {:ok, %MeasurementId{external_source: ^source}} =
          MeasurementId.new_external(source, "test-id")
      end
    end

    test "rejects invalid external sources" do
      assert {:error, :invalid_external_source} =
        MeasurementId.new_external("unknown_source", "test-id")
      assert {:error, :invalid_external_source} =
        MeasurementId.new_external("invalid source", "test-id")
    end

    test "rejects empty or invalid external IDs" do
      assert {:error, :invalid_external_id} =
        MeasurementId.new_external("apple_health", "")
      assert {:error, :invalid_external_id} =
        MeasurementId.new_external("apple_health", "   ")
      assert {:error, :invalid_external_id} =
        MeasurementId.new_external("apple_health", nil)
    end

    test "preserves original external ID formatting" do
      original_id = "  HK-12345-weight  "
      assert {:ok, %MeasurementId{external_id: ^original_id}} =
        MeasurementId.new_external("apple_health", original_id)
    end
  end

  describe "from_external/3 - reconstruct from complete info" do
    test "creates measurement ID from complete external information" do
      uuid = "123e4567-e89b-12d3-a456-426614174000"

      assert {:ok, %MeasurementId{
        value: ^uuid,
        external_source: "fitbit",
        external_id: "fitbit-measurement-123"
      }} = MeasurementId.from_external(uuid, "fitbit", "fitbit-measurement-123")
    end

    test "handles unspecified source correctly" do
      uuid = "123e4567-e89b-12d3-a456-426614174000"

      assert {:ok, %MeasurementId{
        external_source: "unspecified"
      }} = MeasurementId.from_external(uuid, nil, "external-id")
    end

    test "rejects invalid UUID" do
      assert {:error, :invalid_uuid} =
        MeasurementId.from_external("not-uuid", "apple_health", "test-id")
    end

    test "rejects invalid external source" do
      uuid = "123e4567-e89b-12d3-a456-426614174000"
      assert {:error, :invalid_external_source} =
        MeasurementId.from_external(uuid, "invalid_source", "test-id")
    end
  end

  describe "external?/1" do
    test "returns false for internal measurements" do
      id = MeasurementId.new()
      assert MeasurementId.external?(id) == false
    end

    test "returns true for external measurements" do
      {:ok, id} = MeasurementId.new_external("apple_health", "test-id")
      assert MeasurementId.external?(id) == true
    end
  end

  describe "external_reference/1" do
    test "returns nil for internal measurements" do
      id = MeasurementId.new()
      assert MeasurementId.external_reference(id) == nil
    end

    test "returns source and ID tuple for external measurements" do
      {:ok, id} = MeasurementId.new_external("apple_health", "HK-12345")
      assert MeasurementId.external_reference(id) == {"apple_health", "HK-12345"}
    end

    test "returns unspecified source when originally nil" do
      {:ok, id} = MeasurementId.new_external(nil, "unknown-id")
      assert MeasurementId.external_reference(id) == {"unspecified", "unknown-id"}
    end
  end

  describe "valid_external_sources/0" do
    test "returns list of valid external sources" do
      sources = MeasurementId.valid_external_sources()

      assert is_list(sources)
      assert "apple_health" in sources
      assert "google_fit" in sources
      assert "fitbit" in sources
      assert "unspecified" in sources
    end
  end

  describe "equality" do
    test "two measurement IDs with same UUID are equal regardless of external info" do
      uuid = "123e4567-e89b-12d3-a456-426614174000"
      {:ok, id1} = MeasurementId.from_uuid(uuid)
      {:ok, id2} = MeasurementId.from_external(uuid, "apple_health", "test-id")

      # Note: This tests structural equality - in practice you might want
      # business equality that considers external info
      assert id1.value == id2.value
    end

    test "measurement IDs with different UUIDs are not equal" do
      id1 = MeasurementId.new()
      id2 = MeasurementId.new()

      assert id1.value != id2.value
    end
  end
end
