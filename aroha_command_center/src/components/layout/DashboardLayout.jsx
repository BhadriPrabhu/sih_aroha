import React from 'react';
import { NavLink } from 'react-router-dom';
import { LayoutDashboard, Activity, Anchor, Users, AlertTriangle, Settings, Bell, Search } from 'lucide-react';

export default function DashboardLayout({ children }) {
    return (
        <div className="flex h-screen bg-slate-50 text-slate-900 font-sans">
            {/* Sidebar - Tactical Slate Theme */}
            <aside className="w-64 bg-slate-900 border-r border-slate-800 flex flex-col transition-all duration-300">
                <div className="p-5 flex items-center gap-3 border-b border-slate-800">
                    <div className="w-8 h-8 bg-sky-600 rounded-md flex items-center justify-center text-white font-bold shadow-sm">
                        A
                    </div>
                    <div>
                        <span className="font-bold text-base text-slate-100 tracking-tight block leading-tight">AROHA</span>
                        <span className="text-[10px] font-medium text-slate-400 uppercase tracking-widest">NCPOR Central</span>
                    </div>
                </div>

                <nav className="flex-1 py-4 space-y-1 overflow-y-auto">
                    <p className="text-[10px] font-bold text-slate-500 mb-2 mt-2 px-5 uppercase tracking-wider">Cross-Station Ops</p>
                    <NavItem to="/" icon={<LayoutDashboard size={16} />} label="Command Center" exact />
                    <NavItem to="/inventory" icon={<Activity size={16} />} label="Inventory & Risk" />
                    <NavItem to="/cargo" icon={<Anchor size={16} />} label="Cargo & Resupply" />

                    <p className="text-[10px] font-bold text-slate-500 mt-6 mb-2 px-5 uppercase tracking-wider">Field Assets</p>
                    <NavItem to="/expeditions" icon={<Users size={16} />} label="Expeditions" />
                    <NavItem to="/alerts" icon={<AlertTriangle size={16} />} label="Burst Channel" alert />

                    <p className="text-[10px] font-bold text-slate-500 mt-6 mb-2 px-5 uppercase tracking-wider">System</p>
                    <NavItem to="/settings" icon={<Settings size={16} />} label="Recalibration" />
                </nav>
            </aside>

            {/* Main Content */}
            <main className="flex-1 flex flex-col min-w-0 overflow-hidden">
                {/* Topbar - Structured & Monotone */}
                <header className="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-6">
                    <div className="text-lg font-bold text-slate-900 tracking-tight">
                        Dashboard
                    </div>

                    <div className="flex items-center gap-4">
                        <div className="relative">
                            <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                            <input
                                type="text"
                                placeholder="Search station, item ID..."
                                className="pl-9 pr-3 py-1.5 bg-slate-50 border border-slate-200 rounded-md text-sm focus:outline-none focus:ring-1 focus:ring-sky-500 w-64 transition-all"
                            />
                        </div>
                        <button className="text-slate-500 hover:text-slate-800 relative bg-white p-1.5 rounded-md border border-slate-200 shadow-sm transition-colors">
                            <Bell size={18} />
                            <span className="absolute -top-1 -right-1 w-2 h-2 bg-rose-600 rounded-full border border-white"></span>
                        </button>
                        <button
                            type="button"
                            className="group flex items-center gap-2 bg-white pl-1.5 pr-3 py-1 rounded-md shadow-sm border border-slate-200 hover:bg-slate-50 transition-all focus:outline-none focus:ring-1 focus:ring-slate-300"
                        >
                            <div className="flex items-center justify-center w-6 h-6 rounded bg-slate-200 text-xs font-bold text-slate-700">
                                A
                            </div>
                            <span className="text-xs font-semibold text-slate-700 group-hover:text-slate-900">
                                Cmdr. Alex
                            </span>
                        </button>
                    </div>
                </header>

                {/* Page Content */}
                <div className="flex-1 overflow-auto p-6 bg-slate-50">
                    {children}
                </div>
            </main>
        </div>
    );
}

// Sub-component: NavItem optimized for enterprise density and structure
function NavItem({ to, icon, label, exact, alert }) {
    return (
        <NavLink
            to={to}
            end={exact}
            className={({ isActive }) => `flex items-center justify-between px-5 py-2.5 text-sm font-medium transition-colors border-l-2 ${isActive
                    ? 'bg-slate-800 border-sky-400 text-white'
                    : 'border-transparent text-slate-400 hover:bg-slate-800/50 hover:text-slate-200'
                }`}
        >
            <div className="flex items-center gap-3">
                {icon}
                {label}
            </div>
            {alert && <span className="w-2 h-2 rounded bg-rose-600"></span>}
        </NavLink>
    );
}