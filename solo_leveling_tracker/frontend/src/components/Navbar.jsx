import React from 'react';
import { NavLink } from 'react-router-dom';
import { User, CheckSquare, Briefcase, Zap } from 'lucide-react';

const Navbar = () => {
  const getNavClass = ({ isActive }) =>
    `flex flex-col items-center justify-center w-full h-full space-y-1 transition-all duration-300 ${
      isActive
        ? 'text-neon-blue drop-shadow-[0_0_8px_rgba(0,210,255,0.8)]'
        : 'text-gray-500 hover:text-white hover:drop-shadow-[0_0_5px_rgba(255,255,255,0.5)]'
    }`;

  const getIndicatorClass = ({ isActive }) =>
    `absolute top-0 w-1/2 h-0.5 bg-neon-blue transition-opacity duration-300 rounded-b-md shadow-[0_0_10px_#00d2ff] ${
      isActive ? 'opacity-100' : 'opacity-0'
    }`;

  return (
    <nav className="fixed bottom-0 left-0 w-full h-16 sm:h-20 bg-black/60 backdrop-blur-2xl border-t border-white/10 z-50">
      <div className="max-w-4xl mx-auto h-full grid grid-cols-4 gap-1 relative px-2">
        
        <NavLink to="/" className="relative flex justify-center h-full group">
          {({ isActive }) => (
            <>
              <div className={getIndicatorClass({ isActive })} />
              <div className={getNavClass({ isActive })}>
                <User size={24} strokeWidth={isActive ? 2.5 : 2} className="group-hover:scale-110 transition-transform" />
                <span className="text-[10px] uppercase font-system tracking-wider">Status</span>
              </div>
            </>
          )}
        </NavLink>

        <NavLink to="/quests" className="relative flex justify-center h-full group">
          {({ isActive }) => (
            <>
              <div className={getIndicatorClass({ isActive })} />
              <div className={getNavClass({ isActive })}>
                <CheckSquare size={24} strokeWidth={isActive ? 2.5 : 2} className="group-hover:scale-110 transition-transform" />
                <span className="text-[10px] uppercase font-system tracking-wider">Quests</span>
              </div>
            </>
          )}
        </NavLink>

        <NavLink to="/inventory" className="relative flex justify-center h-full group">
          {({ isActive }) => (
            <>
              <div className={getIndicatorClass({ isActive })} />
              <div className={getNavClass({ isActive })}>
                <Briefcase size={24} strokeWidth={isActive ? 2.5 : 2} className="group-hover:scale-110 transition-transform" />
                <span className="text-[10px] uppercase font-system tracking-wider">Inventory</span>
              </div>
            </>
          )}
        </NavLink>

        <NavLink to="/skills" className="relative flex justify-center h-full group">
          {({ isActive }) => (
            <>
              <div className={getIndicatorClass({ isActive })} />
              <div className={getNavClass({ isActive })}>
                <Zap size={24} strokeWidth={isActive ? 2.5 : 2} className="group-hover:scale-110 transition-transform" />
                <span className="text-[10px] uppercase font-system tracking-wider">Skills</span>
              </div>
            </>
          )}
        </NavLink>

      </div>
    </nav>
  );
};

export default Navbar;
