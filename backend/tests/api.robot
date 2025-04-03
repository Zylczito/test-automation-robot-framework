*** Settings ***
Library    RequestsLibrary

*** Variables ***

${PROXY_HEALTH_URL}     http://proxy/health
${PROXY_ARTICLES}        http://proxy/articles/

*** Test Cases ***

TC_01: Verify Get Request
    ${response}=  GET  ${PROXY_HEALTH_URL}  expected_status=200

TC_02: Verify Post Request
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=  POST  ${PROXY_ARTICLES}  data={"title":"test","content":"test"}  headers=${headers}  expected_status=201

TC_03: Pobranie listy artykułów dwukrotnie i sprawdzenie, że liczba artykułów się nie zmieniła
    ${response1}=    GET    ${PROXY_ARTICLES}
    ${first}=    Get Length    ${response1.json()}
    Log To Console    ${first}
    ${response2}=    GET    ${PROXY_ARTICLES}
    ${second}=    Get Length    ${response2.json()}
    Log To Console    ${second}
    Should Be Equal    ${first}    ${second}

TC_04: Próba usunięcia nieistniejącego artykułu i sprawdzenie, że zwrócony został błąd 404
    DELETE    ${PROXY_ARTICLES}666    expected_status=404

TC_05: Próba dodania artykułu bez tytułu i sprawdzenie, że zwrócony został błąd 400 wraz ze stosowną informacją
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${data}=    Create Dictionary    content=asd
    ${response}=    POST    ${PROXY_ARTICLES}    json=${data}    headers=${headers}    expected_status=400

TC_06: Dodawanie/usuwanie artykulow
    ${response}=    GET    ${PROXY_ARTICLES}    expected_status=200
    ${articles}=    Set Variable    ${response.json()}
    FOR    ${article}    IN    @{articles}
        Should Not Contain    ${article["title"]}    test00
    END

TC_07: Dodanie artykułu Y
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=  POST  http://proxy/articles/  data={"title":"test00","content":"test"}  headers=${headers}    expected_status=201

TC_08: Pobranie listy artykułów i sprawdzenie, że artykuł Y jest na liście
    ${response}=    GET    ${PROXY_ARTICLES}    expected_status=200
    ${articles}=    Set Variable    ${response.json()}
    ${titles}=    Evaluate    [a["title"] for a in ${articles}]    json
    Should Contain  ${titles}  test00
TC_09: Usunięcie artykułu Y
    ${response}=    GET    ${PROXY_ARTICLES}     expected_status=200
    ${articles}=    Set Variable    ${response.json()}
    ${found}=    Evaluate    next((a for a in ${articles} if a["title"] == 'test00'), None)    json
    DELETE  ${PROXY_ARTICLES}${found['id']}  expected_status=204

TC_10: Pobranie listy artkułów i sprawdzenie, że nie ma tam artykułu Y
    ${response}=    GET    ${PROXY_ARTICLES}    expected_status=200
    ${articles}=    Set Variable    ${response.json()}
    FOR    ${article}    IN    @{articles}
        Should Not Contain    ${article["title"]}    test00
    END