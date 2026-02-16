// Package webhook provides event types and structures for webhook callbacks.
package webhook

import (
	"time"
)

// Event type constants representing different webhook event types.
const (
	// EventConversionSuccess is dispatched when a conversion completes successfully.
	EventConversionSuccess = "conversion.success"

	// EventConversionError is dispatched when a conversion fails.
	EventConversionError = "conversion.error"

	// EventUploadSuccess is dispatched when file upload to webhook URL succeeds.
	EventUploadSuccess = "upload.success"

	// EventUploadError is dispatched when file upload to webhook URL fails.
	EventUploadError = "upload.error"
)

// Event represents a webhook event with structured data.
type Event struct {
	// Event is the type of event (e.g., "upload.success", "conversion.error").
	Event string `json:"event"`

	// Trace is the trace identifier for request tracking.
	Trace string `json:"trace"`

	// Timestamp is the ISO 8601 formatted timestamp when the event occurred.
	Timestamp string `json:"timestamp"`

	// Details contains event-specific data.
	Details map[string]interface{} `json:"details"`
}

// newUploadSuccessEvent creates an upload.success event.
func newUploadSuccessEvent(trace string, url string, bytes int64, latencyMs int64) Event {
	return Event{
		Event:     EventUploadSuccess,
		Trace:     trace,
		Timestamp: time.Now().UTC().Format(time.RFC3339Nano),
		Details: map[string]interface{}{
			"url":        url,
			"bytes":      bytes,
			"latency_ms": latencyMs,
		},
	}
}

// newUploadErrorEvent creates an upload.error event.
func newUploadErrorEvent(trace string, status int, message string) Event {
	return Event{
		Event:     EventUploadError,
		Trace:     trace,
		Timestamp: time.Now().UTC().Format(time.RFC3339Nano),
		Details: map[string]interface{}{
			"status":  status,
			"message": message,
		},
	}
}

// newConversionSuccessEvent creates a conversion.success event.
func newConversionSuccessEvent(trace string) Event {
	return Event{
		Event:     EventConversionSuccess,
		Trace:     trace,
		Timestamp: time.Now().UTC().Format(time.RFC3339Nano),
		Details:   map[string]interface{}{},
	}
}

// newConversionErrorEvent creates a conversion.error event.
func newConversionErrorEvent(trace string, status int, message string) Event {
	return Event{
		Event:     EventConversionError,
		Trace:     trace,
		Timestamp: time.Now().UTC().Format(time.RFC3339Nano),
		Details: map[string]interface{}{
			"status":  status,
			"message": message,
		},
	}
}
