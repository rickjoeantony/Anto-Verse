// src/hooks/useDynamicLighting.js
import { useEffect } from 'react';

export function useDynamicLighting(containerRef, enabled = true) {
  useEffect(() => {
    if (!enabled) return;

    const handlePointerMove = (e) => {
      const target = containerRef?.current || document.documentElement;
      const rect = target.getBoundingClientRect();
      const x = ((e.clientX - rect.left) / rect.width) * 100;
      const y = ((e.clientY - rect.top) / rect.height) * 100;

      target.style.setProperty('--light-x', `${Math.max(0, Math.min(100, x))}%`);
      target.style.setProperty('--light-y', `${Math.max(0, Math.min(100, y))}%`);
    };

    window.addEventListener('pointermove', handlePointerMove);
    return () => window.removeEventListener('pointermove', handlePointerMove);
  }, [containerRef, enabled]);
}

export default useDynamicLighting;
