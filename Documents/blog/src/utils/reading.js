// Reading time: ~200 words per minute
export const getReadingTime = (content = '') => {
  const words = content.trim().split(/\s+/).length;
  const minutes = Math.max(1, Math.ceil(words / 200));
  return `${minutes} min read`;
};
