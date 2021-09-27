ARG BUILD_IMAGE=mcr.microsoft.com/windows/servercore:1809
ARG FROM_IMAGE=mcr.microsoft.com/windows/servercore:1809

FROM $BUILD_IMAGE as build

ARG OTP_VERSION
ARG OTP_HASH

# ADD https://github.com/erlang/otp/releases/download/OTP-${OTP_VERSION}/otp_win64_${OTP_VERSION}.exe ./otp-installer.exe
ADD otp-installer.exe otp-installer.exe


SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN if ((Get-FileHash ".\otp-installer.exe" -Algorithm SHA256).Hash -ne $Env:OTP_HASH) { exit 1; }

RUN Start-Process -Wait -FilePath ".\otp-installer.exe" -ArgumentList /S

FROM $FROM_IMAGE

ARG OTP_VERSION

COPY --from=build ["C:/Program Files/erl-${OTP_VERSION}", "C:/Program Files/erl-${OTP_VERSION}"]

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN setx /M PATH $($Env:PATH + ';C:\Program Files\erl-' + $Env:OTP_VERSION + '\bin')

CMD [ "erl.exe" ]
