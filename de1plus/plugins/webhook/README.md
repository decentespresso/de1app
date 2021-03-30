# "Webhook" DE1app plugin

This plugin provides functionality to trigger a webhook after a shot has completed.

Much of the code is directly inspired by the `visualizer_upload` plugin.

## Why?

If you are a programmer, you may have some automations or other things you may want to trigger as a result of pulling a shot of espresso. Having a way to receive a webhook, or push notification in a sense, makes it much easier to trigger your automation.

## Settings

The plugin provides the following settings to be configured:

- `webhook_domain` (default: `example.com`) - The domain/origin for the website serving the webhook. This should _not_ include the protocol or any part of the path.
- `webhook_endpoint` (default: `/decent/webhook`) - The resource path where the webhook should POST to.
- `webhook_secret_key` (default: `SecretKeyForSigning`) - This is the key used for generating the HMAC signature, which is passed as part of the `Authorization` header.
- `webhook_trigger_after` (default: `10`) - Number of seconds to wait after flow completes before triggering the webhook.

## Behavior

- After a shot completes (`after_flow_complete`) and after the built-in `after_flow_complete_delay`, wait an additional `webhook_trigger_after` seconds.
- Send a `POST` request to the specified webhook URL
  - Connect to the `webhook_domain` over TLS.
  - Construct the body as a file attachment of the history file
  - Calculate the HMAC signature
  - Send the `POST` request with the appropriate `Authorization` header to `https://$webhook_domain$webhook_endpoint`.

## HMAC Verification

As a best practice with webhooks, you should be verifying the authenticity of the message being sent. We use HMAC to accomplish this to verify both the sender's identity and the message's validity. The plugin will automatically calculate an HMAC signature and send it in the `Authorization` header. The header will look something like below:

```
Authorization: 1617092331!f728a8092b6882749efa61a6609414d14c6f25286bdb1fd76e0dda4bab0f0cdf
               ^ clock    ^ HMAC signature
```

Where `1617092331` represents the clock at the time of the shot, and `f728a8092b6882749efa61a6609414d14c6f25286bdb1fd76e0dda4bab0f0cdf` is the calculated HMAC signature. Note that they are delimited by the character `!`.

The signature calculation for verifying on your server-side should look like the following:

```
HMAC_SHA256($webhook_secret_key, "$webhook_endpoint\n$clock\n$body")
```

It can also be good to check against replay attacks by verifying that the clock time is not too old.
