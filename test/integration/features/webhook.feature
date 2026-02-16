# TODO:
# 1. Other HTTP Methods
# 2. Errors

@webhook
Feature: Webhook

  Scenario: Default
    Given I have a default Gotenberg container
    Given I have a webhook server
    When I make a "POST" request to Gotenberg at the "/forms/pdfengines/flatten" endpoint with the following form data and header(s):
      | files                       | testdata/page_1.pdf                          | file   |
      | Gotenberg-Webhook-Url       | http://host.docker.internal:%d/webhook       | header |
      | Gotenberg-Webhook-Error-Url | http://host.docker.internal:%d/webhook/error | header |
    Then the response status code should be 204
    When I wait for the asynchronous request to the webhook
    Then the webhook request header "Content-Type" should be "application/pdf"
    Then there should be 1 PDF(s) in the webhook request

  Scenario: Extra HTTP Headers
    Given I have a default Gotenberg container
    Given I have a webhook server
    When I make a "POST" request to Gotenberg at the "/forms/pdfengines/flatten" endpoint with the following form data and header(s):
      | files                                | testdata/page_1.pdf                            | file   |
      | Gotenberg-Webhook-Url                | http://host.docker.internal:%d/webhook         | header |
      | Gotenberg-Webhook-Error-Url          | http://host.docker.internal:%d/webhook/error   | header |
      | Gotenberg-Webhook-Extra-Http-Headers | {"X-Foo":"bar","Content-Disposition":"inline"} | header |
    Then the response status code should be 204
    When I wait for the asynchronous request to the webhook
    Then the webhook request header "Content-Type" should be "application/pdf"
    Then the webhook request header "X-Foo" should be "bar"
    # https://github.com/gotenberg/gotenberg/issues/1165
    Then the webhook request header "Content-Disposition" should be "inline"
    Then there should be 1 PDF(s) in the webhook request

  Scenario: Synchronous
    Given I have a Gotenberg container with the following environment variable(s):
      | WEBHOOK_ENABLE_SYNC_MODE | true |
    Given I have a webhook server
    When I make a "POST" request to Gotenberg at the "/forms/pdfengines/flatten" endpoint with the following form data and header(s):
      | files                       | testdata/page_1.pdf                          | file   |
      | Gotenberg-Webhook-Url       | http://host.docker.internal:%d/webhook       | header |
      | Gotenberg-Webhook-Error-Url | http://host.docker.internal:%d/webhook/error | header |
    Then the response status code should be 204
    Then the webhook request header "Content-Type" should be "application/pdf"
    Then there should be 1 PDF(s) in the webhook request

  Scenario: Upload Success Callback
    Given I have a default Gotenberg container
    Given I have a webhook server
    When I make a "POST" request to Gotenberg at the "/forms/pdfengines/flatten" endpoint with the following form data and header(s):
      | files                                    | testdata/page_1.pdf                                  | file   |
      | Gotenberg-Webhook-Url                    | http://host.docker.internal:%d/webhook               | header |
      | Gotenberg-Webhook-Error-Url              | http://host.docker.internal:%d/webhook/error         | header |
      | Gotenberg-Webhook-Upload-Success-Url     | http://host.docker.internal:%d/webhook/upload-success | header |
    Then the response status code should be 204
    When I wait for the asynchronous request to the webhook
    Then the webhook request header "Content-Type" should be "application/pdf"
    Then there should be 1 PDF(s) in the webhook request
    Then the webhook should have received 1 event callback(s)
    Then the webhook event 1 header "X-Gotenberg-Event" should be "upload.success"
    Then the webhook event 1 body should match JSON:
      """
      {
        "event": "upload.success"
      }
      """

  Scenario: Events URL Receives All Events
    Given I have a default Gotenberg container
    Given I have a webhook server
    When I make a "POST" request to Gotenberg at the "/forms/pdfengines/flatten" endpoint with the following form data and header(s):
      | files                           | testdata/page_1.pdf                          | file   |
      | Gotenberg-Webhook-Url           | http://host.docker.internal:%d/webhook       | header |
      | Gotenberg-Webhook-Error-Url     | http://host.docker.internal:%d/webhook/error | header |
      | Gotenberg-Webhook-Events-Url    | http://host.docker.internal:%d/webhook/events | header |
    Then the response status code should be 204
    When I wait for the asynchronous request to the webhook
    Then the webhook request header "Content-Type" should be "application/pdf"
    Then there should be 1 PDF(s) in the webhook request
    Then the webhook should have received 2 event callback(s)
    Then the webhook event 1 header "X-Gotenberg-Event" should be "conversion.success"
    Then the webhook event 1 body should match JSON:
      """
      {
        "event": "conversion.success"
      }
      """
    Then the webhook event 2 header "X-Gotenberg-Event" should be "upload.success"
    Then the webhook event 2 body should match JSON:
      """
      {
        "event": "upload.success"
      }
      """

