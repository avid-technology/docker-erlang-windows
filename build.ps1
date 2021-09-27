param (
  $from_image_repo="mcr.microsoft.com",
  $from_image_name="windows/servercore",
  $from_image_tag="20H2",

  $otp_version="24.0.4",
  $otp_hash="A69E439C7C6266B523CBDF66036CEA4597BE477E6914498551C9FBC54FE5770F",

  $repo="erlang"
)

$from_image = "${from_image_repo}/${from_image_name}:${from_image_tag}"

$windows_tag = ($from_image_name.Split("/") + $from_image_tag) -join "-"
$otp_version_major = ($otp_version.Split("."))[0]

$otp_tag_precise = @($otp_version, $windows_tag) -join "-"
$otp_tag_rough = @($otp_version_major, $windows_tag) -join "-"

$image_precise = "${repo}:${otp_tag_precise}"
$image_rough = "${repo}:${otp_tag_rough}"

docker build `
  --build-arg "OTP_VERSION=$otp_version" `
  --build-arg "FROM_IMAGE=$from_image" `
  -t $image_precise `
  -t $image_rough `
  .

# If ($Env:CI -eq "true") {
#   docker push $image_precise
#   docker push $image_rough
# }
