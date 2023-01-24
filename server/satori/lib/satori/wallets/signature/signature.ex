defmodule Satori.Wallets.Ravencoin do
  @magic "Raven Signed Message:\n"

  # serialize data
  @spec serialize(binary) :: binary
  def serialize(data) do
    serialize_binary(@magic) <> serialize_binary(data)
  end

  # serialize binary
  @spec serialize_binary(binary) :: binary
  defp serialize_binary(data) do
    serialize_integer(byte_size(data)) <> data
  end

  # serialize variable sized integer
  @spec serialize_integer(integer) :: binary
  defp serialize_integer(value) do
    cond do
      value < 0 -> raise "varint must be a non-negative integer"
      value < 0xFD -> <<value>>
      value <= 0xFFFF -> <<0xFD, value::16-little>>
      value <= 0xFFFFFFFF -> <<0xFE, value::32-little>>
      true -> <<0xFF, value::64-little>>
    end
  end
end

defmodule Satori.Wallets.Signature do
  alias Satori.Wallets.Ravencoin

  @doc """
  Verify a signature.

  ## Parameters
  - message: the message in plain text
  - signature: signature encoded in base 64
  - public_key: the public key encoded in base 16
  """
  @spec verify!(binary, String.t(), String.t()) :: true | false
  def verify!(message, signature, public_key) do
    dersig = der_from_signature(signature |> Base.decode64!(ignore: :whitespace))
    public_key = [public_key |> Base.decode16!(case: :mixed), :secp256k1]
    doublehash = :crypto.hash(:sha256, :crypto.hash(:sha256, Ravencoin.serialize(message)))
    :crypto.verify(:ecdsa, :sha256, {:digest, doublehash}, dersig, public_key)
  end

  @doc "Ditto"
  @spec verify(binary, String.t(), String.t()) :: {:ok, true} | {:ok, false} | {:err, String.t()}
  def verify(message, signature, public_key) do
    {:ok, verify!(message, signature, public_key)}
  rescue
    e -> {:error, Exception.message(e)}
  end

  # Convert singnature to DER.
  @spec der_from_signature(binary) :: binary
  defp der_from_signature(sig) do
    unless byte_size(sig) == 65 do
      raise "expected signature to be 65 bytes long, got #{byte_size(sig)} bytes"
    end

    <<_, r::binary-size(32), s::binary-size(32)>> = sig
    r = redo_der_integer_padding(r)
    s = redo_der_integer_padding(s)
    r_size = encode_asn1_length(byte_size(r))
    s_size = encode_asn1_length(byte_size(s))
    seq_size = 1 + byte_size(r_size) + byte_size(r) + 1 + byte_size(s_size) + byte_size(s)
    <<0x30>> <> encode_asn1_length(seq_size) <> <<0x2>> <> r_size <> r <> <<0x2>> <> s_size <> s
  end

  # Redo the padding of a DER integer.
  @spec redo_der_integer_padding(binary) :: binary
  defp redo_der_integer_padding(bn) do
    bn = String.trim_leading(bn, <<0>>)
    <<tip, _::binary>> = bn
    padding = if tip > 127, do: <<0>>, else: <<>>
    padding <> bn
  end

  # Encode ASN1 length.
  @spec encode_asn1_length(integer) :: binary
  defp encode_asn1_length(length) do
    if length < 128 do
      <<length>>
    else
      bytes = :binary.encode_unsigned(length, :little)
      <<128 + byte_size(bytes)>> <> bytes
    end
  end
end

# unless length(System.argv()) == 3 do
#   IO.puts "Verify a signature."
#   IO.puts "usage: <message> <signature-in-base64> <private-key-in-base16>"
#   System.halt(1)
# end

# [message, signature, public_key] = System.argv()

# case Satori.Wallets.Signature.verify(message, signature, public_key) do
#   {:ok, true} -> IO.puts "Signature Verified Successfully"
#   {:ok, false} -> IO.puts "Signature Verification Failure"
#   {:error, error} -> IO.puts "error: #{error}"
# end
