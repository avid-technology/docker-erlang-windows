param (
  $from_image_repo="mcr.microsoft.com",
  $from_image_name="windows/servercore",
  $from_image_tag="20H2",

  $otp_version="24.0.6",
  $otp_hash="29AB0BF965129A6D7E6E1E46790BF2B7C37A31AD6F958B7F15AB3C1FCA08DEF0",

  $repo="erlang"
)

$from_image = "${from_image_repo}/${from_image_name}:${from_image_tag}"

$windows_tag = ($from_image_name.Split("/") + $from_image_tag) -join "-"
$otp_tag = @($otp_version, $windows_tag) -join "-"
$tag= "${repo}:${otp_tag}"

docker build `
  --build-arg "OTP_VERSION=$otp_version" `
  --build-arg "OTP_HASH=$otp_hash" `
  --build-arg "FROM_IMAGE=$from_image" `
  -t $tag `
  .

If ($Env:CI -eq "true") {
  docker push $tag
}
