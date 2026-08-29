// src/screens/MessagesAppScreen.jsx
import React, { useState } from 'react';
import {
  Send,
  Mic,
  Camera,
  Play,
  Pause,
  Smile,
  Heart,
  ThumbsUp,
  Sparkles,
  ShieldCheck,
  Zap
} from 'lucide-react';
import IosNavigationBar from '../components/ios/IosNavigationBar';
import sounds from '../utils/soundEffects';

export default function MessagesAppScreen({ isDark, onToggleTheme, onOpenSettings }) {
  const [messages, setMessages] = useState([
    {
      id: 1,
      sender: 'Dr. Rick J. Antony',
      avatar: 'RA',
      text: "The new iOS 26 Liquid Glass interface with Swift 6 Strict Concurrency is completely zero-dependency and running at 120 FPS!",
      isMe: false,
      timestamp: "9:32 AM",
      tapbacks: ['❤️', '🔥']
    },
    {
      id: 2,
      sender: 'You',
      text: "Just simulated a high-speed telemetry ingress on the Ghost-Net honeypot. Glassmorphism refraction and dynamic lighting look spectacular!",
      isMe: true,
      timestamp: "9:34 AM",
      tapbacks: ['👍']
    },
    {
      id: 3,
      sender: 'Dr. Rick J. Antony',
      avatar: 'RA',
      type: 'voice',
      duration: '0:14',
      isMe: false,
      timestamp: "9:36 AM",
      tapbacks: []
    }
  ]);

  const [inputMessage, setInputMessage] = useState('');
  const [isPlayingVoice, setIsPlayingVoice] = useState(false);

  const handleSend = () => {
    if (!inputMessage.trim()) return;
    sounds.playPop();
    const newMsg = {
      id: Date.now(),
      sender: 'You',
      text: inputMessage,
      isMe: true,
      timestamp: "Just now",
      tapbacks: []
    };
    setMessages(prev => [...prev, newMsg]);
    setInputMessage('');

    // Trigger auto reply
    setTimeout(() => {
      sounds.playChime();
      const reply = {
        id: Date.now() + 1,
        sender: 'Dr. Rick J. Antony',
        avatar: 'RA',
        text: "Verified! Quantum honeypot has quarantined all rogue subnet probes.",
        isMe: false,
        timestamp: "Just now",
        tapbacks: ['✨']
      };
      setMessages(prev => [...prev, reply]);
    }, 1500);
  };

  const handleAddReaction = (msgId, emoji) => {
    sounds.playTap();
    setMessages(prev =>
      prev.map(m =>
        m.id === msgId ? { ...m, tapbacks: [...m.tapbacks, emoji] } : m
      )
    );
  };

  return (
    <div className="flex-1 flex flex-col pb-6">
      <IosNavigationBar
        title="Messages 26"
        subtitle="Dr. Rick J. Antony • SOC Lead"
        isDark={isDark}
        onToggleTheme={onToggleTheme}
        onOpenSettings={onOpenSettings}
      />

      {/* Messages Thread */}
      <div className="flex-1 p-4 space-y-4 overflow-y-auto no-scrollbar">
        <div className="text-center text-[11px] font-bold text-gray-400 uppercase tracking-wider py-1">
          Today 9:41 AM • End-to-End Encrypted Glass
        </div>

        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex flex-col ${msg.isMe ? 'items-end' : 'items-start'} space-y-1 relative group`}
          >
            <div className={`flex items-end gap-2 max-w-[82%] ${msg.isMe ? 'flex-row-reverse' : 'flex-row'}`}>
              {/* Avatar */}
              {!msg.isMe && (
                <div className="w-8 h-8 rounded-full bg-gradient-to-tr from-indigo-500 to-purple-600 text-white font-bold text-[12px] flex items-center justify-center shadow-md border border-white/20 shrink-0">
                  {msg.avatar}
                </div>
              )}

              {/* Message Bubble (Liquid Glass) */}
              <div
                className={`relative px-4 py-2.5 rounded-[22px] text-[14px] leading-relaxed shadow-lg backdrop-blur-2xl transition-all ${
                  msg.isMe
                    ? 'bg-gradient-to-tr from-ios-blue to-blue-600 text-white border border-blue-400/40 rounded-br-[6px]'
                    : 'ios26-glass text-black dark:text-white rounded-bl-[6px]'
                }`}
              >
                {/* Voice Note View */}
                {msg.type === 'voice' ? (
                  <div className="flex items-center gap-3 py-1 min-w-[170px]">
                    <button
                      onClick={() => {
                        sounds.playTap();
                        setIsPlayingVoice(!isPlayingVoice);
                      }}
                      className="w-8 h-8 rounded-full bg-ios-blue text-white flex items-center justify-center shadow-md"
                    >
                      {isPlayingVoice ? <Pause size={14} /> : <Play size={14} className="ml-0.5" />}
                    </button>
                    <div className="flex-1 space-y-1">
                      <div className="flex items-center gap-0.5 h-4">
                        {[40, 70, 90, 60, 30, 80, 100, 50, 60, 40, 85, 30].map((h, i) => (
                          <span
                            key={i}
                            className={`w-1 rounded-full ${
                              isPlayingVoice ? 'bg-ios-blue animate-pulse' : 'bg-gray-400'
                            }`}
                            style={{ height: `${h}%` }}
                          />
                        ))}
                      </div>
                      <div className="text-[10px] font-mono text-gray-400">{msg.duration}</div>
                    </div>
                  </div>
                ) : (
                  <span>{msg.text}</span>
                )}

                {/* Tapbacks Overlay Badge */}
                {msg.tapbacks.length > 0 && (
                  <div
                    className={`absolute -bottom-2 ${
                      msg.isMe ? '-left-2' : '-right-2'
                    } flex items-center gap-0.5 px-2 py-0.5 rounded-full bg-white/90 dark:bg-black/90 border border-white/20 shadow-md text-[11px]`}
                  >
                    {msg.tapbacks.map((tb, i) => (
                      <span key={i}>{tb}</span>
                    ))}
                  </div>
                )}
              </div>
            </div>

            {/* Quick Tapback Reactions on hover/click */}
            <div className="hidden group-hover:flex items-center gap-1.5 px-2 py-1 rounded-full ios26-glass shadow-md text-[13px] animate-in fade-in">
              {['❤️', '👍', '🔥', '✨'].map((emoji) => (
                <button
                  key={emoji}
                  onClick={() => handleAddReaction(msg.id, emoji)}
                  className="hover:scale-125 transition-transform px-1"
                >
                  {emoji}
                </button>
              ))}
            </div>

            <span className="text-[10px] text-[#8E8E93] px-1 font-mono">{msg.timestamp}</span>
          </div>
        ))}
      </div>

      {/* Liquid Glass Input Bar */}
      <div className="px-4 pt-2">
        <div className="p-1.5 rounded-[28px] ios26-glass-thick flex items-center gap-2 shadow-2xl border border-white/25">
          <button
            onClick={() => sounds.playPop()}
            className="w-8 h-8 rounded-full bg-black/5 dark:bg-white/10 flex items-center justify-center text-gray-400 hover:text-black dark:hover:text-white"
          >
            <Camera size={16} />
          </button>

          <input
            type="text"
            value={inputMessage}
            onChange={(e) => setInputMessage(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSend()}
            placeholder="iMessage 26 with Liquid Glass..."
            className="flex-1 bg-transparent text-[14px] text-black dark:text-white placeholder-gray-400 focus:outline-none px-2"
          />

          {inputMessage.trim() ? (
            <button
              onClick={handleSend}
              className="w-8 h-8 rounded-full bg-ios-blue text-white flex items-center justify-center shadow-lg ios-press-spring"
            >
              <Send size={15} className="-ml-0.5 -mt-0.5" />
            </button>
          ) : (
            <button
              onClick={() => {
                sounds.playPop();
                setInputMessage("Apple Intelligence analyzed telemetry signal: OK");
              }}
              className="w-8 h-8 rounded-full bg-black/5 dark:bg-white/10 flex items-center justify-center text-gray-400 hover:text-ios-blue"
            >
              <Mic size={16} />
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
