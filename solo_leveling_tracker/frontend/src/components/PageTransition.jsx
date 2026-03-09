import React from 'react';
import { motion } from 'framer-motion';

const pageVariants = {
  initial: {
    opacity: 0,
    y: 20,
    scale: 0.98,
    filter: 'blur(5px)'
  },
  in: {
    opacity: 1,
    y: 0,
    scale: 1,
    filter: 'blur(0px)'
  },
  out: {
    opacity: 0,
    y: -20,
    scale: 1.02,
    filter: 'blur(5px)'
  }
};

const pageTransition = {
  type: 'spring',
  stiffness: 260,
  damping: 20,
  duration: 0.4
};

const PageTransition = ({ children }) => {
  return (
    <motion.div
      initial="initial"
      animate="in"
      exit="out"
      variants={pageVariants}
      transition={pageTransition}
      className="w-full pb-24" // padding bottom to clear fixed navbar
    >
      {children}
    </motion.div>
  );
};

export default PageTransition;
