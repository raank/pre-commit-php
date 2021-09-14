#!/bin/bash

# shellcheck disable=SC2028,SC2086,SC2089,SC2059,2046,2034

#
# Hook para auxiliar a vida do Programador
#
# - PHP Lint (http://php.net/manual/en/features.commandline.options.php)
# - PHP CodeSniffer (PHPCS + (PHPCBF) (https://github.com/squizlabs/PHP_CodeSniffer)
# - PHP Mess Detector (PHPMD) (https://phpmd.org/)
# - PHP Stan
#
# @version 1.0.0
# @author Felipe Rank <raank92@gmail.com>
##########


# Colors terminal
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
cyan='\033[1;36m'
white='\033[1;37m'
reset='\033[0m'

# variables
DIR="$PWD"
PROJECT=$(basename $DIR)
COMMAND=$1

if [ -z $COMMAND ]; then
  COMMAND='install'
fi

title() {
  printf "\n#\n#$cyan $1 $reset\n#\n"
}

success() {
  printf "\n#\n# 🍺$green $1 $reset\n#\n"
}

info() {
  printf "\n#\n# ☝️$cyan $1 $reset\n#\n"
}

warning() {
  printf "\n#\n# ⚠️ $yellow $1 $reset\n#\n"
}

error() {
  printf "\n#\n# 🤦$red $1 $reset\n#\n"
  exit 1
}

title_subtitle() {
  printf "\n#\n#$cyan $1 $reset\n#$white $2 $reset\n#\n"
}

divider() {
  printf "# -----"
}

error_tip() {
  printf "\n#\n#$red $1 $reset\n#$white $2 $reset\n#\n"
}

curl_install() {
  name=$1
  url=$2
  rename=$3
  global_path=$4
  filename=$(basename $url)

  if [ -z "$rename" ]; then
    extension=${filename%.*}
    rename=${extension##*/}
  fi

  if [ -z "$global_path" ]; then
    global_path="/usr/local/bin/"
  fi

  if ! [ -d "$global_path" ]; then
    mkdir "$global_path"
    chmod a+x "$global_path"
  fi

  global_bin="${global_path}${rename}"

  if [ -f "$global_bin" ]; then
    title_subtitle "${yellow}${name}${white} já está instalado!" "path: ${yellow}${global_bin}"
  else
    download=$(curl -O 2>&1 "$url")
    notfound="Not Found"

    if [ "$(cat $filename)" == "$notfound" ]; then
      rm "$filename"
      error "Arquivo \"$filename\" não existe!"
    fi

    chmod a+x "$filename"
    cp "$filename" "$global_bin"
    title_subtitle "Instalado: ${yellow}${name}" "path: ${yellow}${global_bin}"
  fi
}

composer_install() {
  name=$1
  package=$2
  vendor_path="$HOME/.composer/vendor/${package}"

  if [ -d "$vendor_path" ]; then
    title_subtitle "${yellow}${name}${white} já instalado!" "path: ${yellow}${vendor_path}"
  else
    check=$(curl -O 2>&1 "https://packagist.org/packages/${package}")
    filename=$(basename "$package")
    package_not_found=$(cat < "$filename" | grep "reason=package_not_found")

    if ! [ -z "$package_not_found" ]; then
      rm "$filename"
      error "Pacote do composer: \"${white}${package}${red}\" não existe!"
    fi

    rm "$filename"
    composer global require -q -v --no-progress "$package"

    title_subtitle "Instalado: ${yellow}${name}" "path: ${yellow}${vendor_path}"
  fi
}

install_pre_commit() {
  name="Pre Commit - Executável"
  if ! command -v pre-commit &> /dev/null; then
    error_tip "Pacote não instalado!" "Instale com o comando: ${yellow}pip install pre-commit ${white}OU${yellow} pip3 install pre-commit\n${white}# Volte a rodar o comando: ${yellow}pre-commit-php install"
  fi

  title_subtitle "${yellow}${name}${white} já instalado!" "path: ${yellow}${global_bin}"
}

config_pre_commit() {
  name="Pre Commit"
  global_bin="/usr/local/bin/pre-commit"
  config_file=".pre-commit-config.yaml"
  config_dir="$HOME/.pre-commit"
  config_file_path="${config_dir}/${config_file}"

  if [ -f "$config_file_path" ] && [ -f "${DIR}/.git/hooks/pre-commit" ]; then
    title_subtitle "${yellow}${name}${white} já configurado!" "path: ${yellow}${global_bin}"
  else
    title_subtitle "${yellow}Configurando o pre commit!" "path: ${yellow}${DIR}"

    if ! [ -d "$config_file_path" ]; then
      install_phpstan_neon=$(curl -O 2>&1 https://raw.githubusercontent.com/raank/pre-commit-php/main/phpstan.neon)
      install=$(curl -O 2>&1 https://raw.githubusercontent.com/raank/pre-commit-php/main/.pre-commit-config.yaml.example)

      if ! [ -f "$config_dir" ]; then
        mkdir "$config_dir"
        chmod a+x "$config_dir"
      fi

      mv "${DIR}/.pre-commit-config.yaml.example" "$config_file_path"
      mv "${DIR}/phpstan.neon" "$config_dir"
    fi

    cp "$config_file_path" $DIR

    if command -v pre-commit &> /dev/null; then
      install=$(pre-commit install)
    fi
  fi
}

printf "${cyan}"
cat <<\EOF
 __   __   ___     __   __                ___     __        __
|__) |__) |__     /  ` /  \  |\/|  |\/| |  |     |__) |__| |__)
|    |  \ |___    \__, \__/  |  |  |  | |  |     |    |  | |
EOF
printf "${reset}\n"


if [ "$COMMAND" == 'install' ]; then
  title_subtitle "Configurando ferramentas auxiliares" "${yellow}Instalando!"
  divider

  if ! command -v composer &> /dev/null; then
    error "Composer não está instalado"
  fi

  if ! [ -f "${DIR}/composer.json" ]; then
    error "Você não pode instalar nesse diretório."
  fi

  composer_install "PHP Stan" "phpstan/phpstan"
  divider
  composer_install "PHP Mess Detector" "phpmd/phpmd"
  #divider
  #curl_install "PHP CodeSniffer + PHP Code Beautifier" "https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar"
  #divider
  #curl_install "PHP Code Fixer" "https://cs.symfony.com/download/php-cs-fixer-v3.phar" "php-cs-fixer"
  #divider
  #curl_install "PHP CBF " "https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar"
  divider
  composer_install "PHP Swagger" "zircote/swagger-php"
  divider
  install_pre_commit
  divider
  config_pre_commit
  divider
  title_subtitle "Criando um arquivo de Documentação" "cd /path/folder; pre-commit-php doc {path}"

  #rm "$PWD/phpstan.phar"
  #rm "$PWD/phpmd.phar"
  #rm "$PWD/phpcs.phar"
  #rm "$PWD/php-cs-fixer-v3.phar"
elif [ "$COMMAND" == "doc" ]; then

  #################
  # Instância o arquivo BIN
  #################
  if [ -f "./vendor/bin/openapi" ]; then
    OPENAPI="./vendor/bin/openapi"
  else
    OPENAPI="$HOME/.composer/vendor/bin/openapi"
  fi

  #################
  # Valida se o arquivo de openAPI existe
  #################
  if ! [ -f "$OPENAPI" ]; then
    error "Pacote \"${white}${OPENAPI}${red}\" não está instalado!"
  fi

  OUTPUT=$2

  if [ -z "$OUTPUT" ]; then
    error "Path para output não foi definido"
  fi

  title_subtitle "Criando arquivo de Documentação" "Local: ${yellow}${DIR}"

  ARGUMENTS="$DIR --output $OUTPUT --exclude $DIR/vendor"

  #################
  # Adiciona o arquivo de constantes caso exista
  #################
  if [ -f "$DIR/resources/api/constants.php" ]; then
    ARGUMENTS="$ARGUMENTS --bootstrap ${DIR}/resources/api/constants.php"
  fi

  swagger=$($OPENAPI $ARGUMENTS 2>&1)
  swagger_retval=$?

  if [ $swagger_retval -ne 0 ]; then
    error "Documentação tem alguns erros. Resolva e volte a rodar o comando."

  else
    title_subtitle "${green}Arquivo gerado com sucesso!" "path: ${yellow}${OUTPUT}"
  fi
else
  error "Command notfound!"
fi