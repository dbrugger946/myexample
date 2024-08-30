FROM registry.access.redhat.com/ubi8/dotnet-80-runtime AS base
WORKDIR /app

FROM registry.access.redhat.com/ubi8/dotnet-80 AS build
USER 0
WORKDIR /src
COPY myexample.csproj .
RUN dotnet restore ./myexample.csproj
COPY . .
WORKDIR /src/.
RUN dotnet build myexample.csproj -c Release -o /app/build

FROM build AS publish
RUN dotnet publish myexample.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# for OCP deployment to deal with anyuid privledges
USER root
RUN chown -R 1001:0 /app
USER 1001
EXPOSE 8080

ENTRYPOINT ["dotnet", "myexample.dll"]


