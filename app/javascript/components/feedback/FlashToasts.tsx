import React, { useEffect, useState } from 'react';

export interface FlashMessage {
  type: 'notice' | 'alert';
  text: string;
}

interface FlashToastsProps {
  messages: FlashMessage[];
  closeLabel: string;
}

const VISIBLE_MS = 5000;
const FADE_MS = 300;

const TYPE_CLASS: Record<FlashMessage['type'], string> = {
  notice: 'text-bg-success',
  alert: 'text-bg-danger',
};

// One message in the corner of the screen. It fades out by itself after a few
// seconds, or right away when closed. Rails renders it on the server, so it is
// still readable (it just stays put) without JavaScript.
const Toast = ({ message, closeLabel }: { message: FlashMessage; closeLabel: string }) => {
  const [phase, setPhase] = useState<'visible' | 'fading' | 'gone'>('visible');

  useEffect(() => {
    if (phase === 'gone') return undefined;

    const timer = setTimeout(
      () => setPhase(phase === 'visible' ? 'fading' : 'gone'),
      phase === 'visible' ? VISIBLE_MS : FADE_MS,
    );

    return () => clearTimeout(timer);
  }, [phase]);

  if (phase === 'gone') return null;

  return (
    <div
      className={`toast show align-items-center border-0 ${TYPE_CLASS[message.type]}`}
      style={{ opacity: phase === 'fading' ? 0 : 1, transition: `opacity ${FADE_MS}ms ease` }}
      role="alert"
    >
      <div className="d-flex">
        <div className="toast-body">{message.text}</div>
        <button
          type="button"
          className="btn-close btn-close-white me-2 m-auto"
          aria-label={closeLabel}
          onClick={() => setPhase('fading')}
        />
      </div>
    </div>
  );
};

// Rails flash messages, shown as toasts by the layout.
const FlashToasts = ({ messages, closeLabel }: FlashToastsProps) => (
  <div className="toast-container position-fixed bottom-0 end-0 p-3">
    {messages.map((message) => (
      <Toast key={`${message.type}:${message.text}`} message={message} closeLabel={closeLabel} />
    ))}
  </div>
);

export default FlashToasts;
