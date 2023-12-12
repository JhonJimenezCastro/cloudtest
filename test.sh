ORIGEN="feature/test1"
DESTINO="release"
TOKEN="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"
OWNER="JhonJimenezCastro"
GITHUB_REPOSITORY="cloudtest"

echo -ne "\e[45m[INFO]\e[0m Creando Pull Request para la rama release \e[0m\n"

PR_RESPONSE=$(curl -s -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $TOKEN" \
  https://api.github.com/repos/$OWNER/$GITHUB_REPOSITORY/pulls \
  -d '{
    "title":"Auto-PR: '${ORIGEN}' -> '${DESTINO}'",
    "body":"proceso generado por gitbot",
    "head": "'$ORIGEN'",
    "base": "'$DESTINO'"
  }'
)
sleep 3s

if [[ $(echo "$PR_RESPONSE" | jq -r '.message') == "Validation Failed" ]]; then
   ERROR_MESSAGE=$(echo "$PR_RESPONSE" | jq -r '.errors[0].message')
  if [[ "$ERROR_MESSAGE" == *"A pull request already exists for"* ]]; then

    EXISTING_PR_URL=$(curl -s -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $TOKEN" \
      "https://api.github.com/repos/$OWNER/$GITHUB_REPOSITORY/pulls?state=open" | jq -r ".[] 
      | select(.head.ref == \"$ORIGEN\" and .base.ref == \"$DESTINO\") 
      | .html_url")
      echo -ne "\e[41m[ERROR]\e[0m Ya existe un PR para $ORIGEN -> $DESTINO: $EXISTING_PR_URL\e[0m\n"
  fi
  exit 1
fi

PR_NUMBER=$(echo "$PR_RESPONSE" | jq -r '.number')
PR_URL=$(echo "$PR_RESPONSE" | jq -r '.html_url')

if [[ -z "$PR_NUMBER" ]]; then
  echo -ne "\e[41m[ERROR]\e[0m Error al crear PR ${DESTINO} -> ${DESTINO}\e[0m\n"
  echo -ne "\e[41m[ERROR]\e[0m $PR_RESPONSE \e[0m\n"
  exit 1
fi

echo -ne "\e[42m[SUCCESS]\e[0m Pull Request #${PR_NUMBER} creado exitosamente \e[0m\n"
echo -ne "\e[42m[SUCCESS]\e[0m $PR_URL \e[0m\n"
