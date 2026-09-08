import React from 'react';
import { NavLink } from 'react-router-dom';
import { LayoutDashboard, Activity, Anchor, Users, AlertTriangle, Settings, Bell, Search } from 'lucide-react';

export default function DashboardLayout({ children }) {
    return (
        <div className="flex h-screen bg-[#F3F4F6] text-slate-800">
            {/* Sidebar - Deep Dark Theme */}
            <aside className="w-64 bg-[#140F2D] flex flex-col transition-all duration-300">
                <div className="p-6 flex items-center gap-3">
                    <div className="w-8 h-8 bg-[#6D28D9] rounded-full flex items-center justify-center text-white font-bold shadow-lg shadow-purple-500/30">
                        A
                    </div>
                    <div>
                        <span className="font-bold text-lg text-white tracking-wide block leading-tight">AROHA</span>
                        <span className="text-[10px] font-medium text-purple-300/70 uppercase tracking-widest">NCPOR Central</span>
                    </div>
                </div>

                <nav className="flex-1 px-4 py-4 space-y-2 overflow-y-auto">
                    <p className="text-[11px] font-semibold text-slate-500 mb-3 px-2 uppercase tracking-wider">Cross-Station Ops</p>
                    <NavItem to="/" icon={<LayoutDashboard size={18} />} label="Command Center" exact />
                    <NavItem to="/inventory" icon={<Activity size={18} />} label="Inventory & Risk" />
                    <NavItem to="/cargo" icon={<Anchor size={18} />} label="Cargo & Resupply" />

                    <p className="text-[11px] font-semibold text-slate-500 mt-8 mb-3 px-2 uppercase tracking-wider">Field Assets</p>
                    <NavItem to="/expeditions" icon={<Users size={18} />} label="Expeditions" />
                    <NavItem to="/alerts" icon={<AlertTriangle size={18} />} label="Burst Channel" alert />

                    <p className="text-[11px] font-semibold text-slate-500 mt-8 mb-3 px-2 uppercase tracking-wider">System</p>
                    <NavItem to="/settings" icon={<Settings size={18} />} label="Recalibration" />
                </nav>
            </aside>

            {/* Main Content */}
            <main className="flex-1 flex flex-col min-w-0 overflow-hidden">
                {/* Topbar */}
                <header className="h-20 bg-[#F3F4F6] flex items-center justify-between px-8">
                    <div className="text-xl font-bold text-slate-800">
                        Dashboard
                    </div>

                    <div className="flex items-center gap-6">
                        <div className="relative">
                            <Search className="w-4 h-4 absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
                            <input
                                type="text"
                                placeholder="Search station, item ID..."
                                className="pl-11 pr-4 py-2.5 bg-white border-none rounded-full text-sm shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-100 w-72 transition-all"
                            />
                        </div>
                        <button className="text-slate-400 hover:text-slate-600 relative bg-white p-2.5 rounded-full shadow-sm">
                            <Bell size={18} />
                            <span className="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full"></span>
                        </button>
                        <button
                            type="button"
                            className="group flex items-center gap-3 bg-white pl-1.5 pr-4 py-1.5 rounded-full shadow-sm border border-slate-200 hover:bg-slate-50 hover:shadow hover:border-slate-300 transition-all duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-slate-300 focus:ring-offset-1"
                        >
                            <div className="flex items-center justify-center w-8 h-8 rounded-full bg-slate-200 border-2 border-white text-sm font-bold text-slate-600 shadow-sm group-hover:bg-slate-300 transition-colors duration-200">
                                A
                            </div>
                            <span className="text-sm font-medium text-slate-700 group-hover:text-slate-900 transition-colors duration-200">
                                Cmdr. Alex
                            </span>
                        </button>
                    </div>
                </header>

                {/* Page Content */}
                <div className="flex-1 overflow-auto p-8 pt-2">
                    {children}
                </div>
            </main>
        </div>
    );
}

// Sub-component: NavItem now uses react-router's NavLink
function NavItem({ to, icon, label, exact, alert }) {
    return (
        <NavLink
            to={to}
            end={exact} // 'end' ensures the root '/' only highlights when exactly matching
            className={({ isActive }) => `flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium transition-all ${isActive
                    ? 'bg-[#6D28D9] text-white shadow-md shadow-purple-900/20'
                    : 'text-slate-400 hover:bg-white/5 hover:text-slate-200'
                }`}
        >
            <div className="flex items-center gap-3">
                {icon}
                {label}
            </div>
            {alert && <span className="w-2 h-2 rounded-full bg-red-500 shadow-[0_0_8px_rgba(239,68,68,0.6)]"></span>}
        </NavLink>
    );
}