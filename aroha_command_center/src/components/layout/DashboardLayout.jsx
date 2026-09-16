import React, { useState } from 'react';
import { NavLink } from 'react-router-dom';
import {
    LayoutDashboard, Activity, Anchor, Users, AlertTriangle,
    Settings, Bell, Search, LogOut, ShieldCheck, Radio, CheckCircle2,
    ShieldAlert
} from 'lucide-react';
import useAuthStore from '../../store/useAuthStore';

export default function DashboardLayout({ children }) {
    // Topbar Interactive States
    const [isNotifOpen, setIsNotifOpen] = useState(false);
    const [isProfileOpen, setIsProfileOpen] = useState(false);
    const [searchQuery, setSearchQuery] = useState('');

    const { user, logout } = useAuthStore();
    const currentRole = user?.role || 'USER';

    return (
        <div className="flex h-screen bg-slate-50 text-slate-900 font-sans">
            {/* Sidebar - Tactical Slate Theme */}
            <aside className="w-64 bg-slate-900 border-r border-slate-800 flex flex-col transition-all duration-300 z-20">
                <div className="p-5 flex items-center border-b border-slate-800">
                    {/* <div className="w-8 h-8 bg-sky-600 rounded-md flex items-center justify-center text-white font-bold shadow-sm">
                        A
                    </div> */}
                    <div>
                        <p className="font-logo font-bold text-3xl text-slate-100 tracking-tight leading-tight">AROHA</p>
                        <p className="font-logo text-[16px] font-medium text-slate-400">NCPOR Central</p>
                    </div>
                </div>

                <nav className="flex-1 py-4 space-y-1 overflow-y-auto">
                    {/* Conditional Rendering based on Roles */}
                    {['SUPER_ADMIN', 'ADMIN'].includes(currentRole) && (
                        <>
                            <p className="text-[12px] font-semibold text-slate-500 mb-2 mt-2 px-5">Cross-Station Ops</p>
                            <NavItem to="/" icon={<LayoutDashboard size={16} />} label="Command Center" exact />
                            <NavItem to="/cargo" icon={<Anchor size={16} />} label="Cargo & Resupply" />
                        </>
                    )}

                    {['SUPER_ADMIN', 'ADMIN', 'MANAGER'].includes(currentRole) && (
                        <NavItem to="/inventory" icon={<Activity size={16} />} label="Inventory & Risk" />
                    )}

                    {['SUPER_ADMIN', 'ADMIN', 'EMPLOYEE'].includes(currentRole) && (
                        <>
                            <p className="text-[12px] font-semibold text-slate-500 mt-6 mb-2 px-5">Field Assets</p>
                            <NavItem to="/expeditions" icon={<Users size={16} />} label="Expeditions" />
                        </>
                    )}

                    <NavItem to="/alerts" icon={<AlertTriangle size={16} />} label="Burst Channel" alert />

                    {/* strictly SUPER_ADMIN ONLY */}
                    {currentRole === 'SUPER_ADMIN' && (
                        <>
                            <p className="text-[12px] font-semibold text-slate-500 mt-6 mb-2 px-5">System Administration</p>
                            <NavItem to="/settings" icon={<Settings size={16} />} label="Recalibration" />
                            <NavItem to="/access-control" icon={<ShieldAlert size={16} />} label="Access Control" />
                        </>
                    )}
                </nav>
            </aside>

            {/* Main Content */}
            <main className="flex-1 flex flex-col min-w-0 overflow-hidden relative">
                {/* Topbar - Structured & Interactive */}
                <header className="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-6 z-10">
                    <div className="text-2xl font-bold text-slate-900 tracking-tight">
                        Dashboard
                    </div>

                    <div className="flex items-center gap-4">
                        {/* Interactive Search */}
                        <div className="relative">
                            <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                            <input
                                type="text"
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                placeholder="Search station, item ID..."
                                className="pl-9 pr-3 py-1.5 bg-slate-50 border border-slate-200 rounded-md text-sm focus:outline-none focus:ring-1 focus:ring-sky-500 w-64 transition-all focus:bg-white"
                            />
                        </div>

                        {/* Notifications Dropdown */}
                        <div className="relative">
                            <button
                                onClick={() => { setIsNotifOpen(!isNotifOpen); setIsProfileOpen(false); }}
                                className={`relative p-1.5 rounded-md border shadow-sm transition-colors focus:outline-none focus:ring-2 focus:ring-sky-500 focus:ring-offset-1 ${isNotifOpen ? 'bg-slate-100 border-slate-300 text-slate-900' : 'bg-white border-slate-200 text-slate-500 hover:text-slate-800'
                                    }`}
                            >
                                <Bell size={18} />
                                <span className="absolute -top-1 -right-1 w-2.5 h-2.5 bg-rose-600 rounded-full border-2 border-white"></span>
                            </button>

                            {/* Notification Popover Panel */}
                            {isNotifOpen && (
                                <div className="absolute right-0 mt-2 w-80 bg-white border border-slate-200 rounded-md shadow-lg py-2 z-50">
                                    <div className="px-4 pb-2 border-b border-slate-100 flex justify-between items-center">
                                        <h4 className="text-sm font-bold text-slate-900">System Alerts</h4>
                                        <button className="text-[10px] font-semibold text-sky-600 hover:text-sky-700">Clear All</button>
                                    </div>
                                    <div className="max-h-64 overflow-y-auto">
                                        <NotificationItem
                                            icon={<AlertTriangle size={14} className="text-rose-600" />}
                                            title="Burst Channel: Code 4"
                                            time="2 mins ago"
                                            desc="Generator failure at Field Camp Alpha."
                                            unread
                                        />
                                        <NotificationItem
                                            icon={<Radio size={14} className="text-emerald-600" />}
                                            title="SATCOM Sync Complete"
                                            time="14 mins ago"
                                            desc="Delta payload received from Maitri Station."
                                        />
                                        <NotificationItem
                                            icon={<CheckCircle2 size={14} className="text-slate-500" />}
                                            title="Optimization Run OPT-02"
                                            time="1 hr ago"
                                            desc="Knapsack routine completed successfully."
                                        />
                                    </div>
                                </div>
                            )}
                        </div>

                        {/* User Profile Dropdown */}
                        <div className="relative">
                            <button
                                onClick={() => { setIsProfileOpen(!isProfileOpen); setIsNotifOpen(false); }}
                                className={`group flex items-center gap-2 pl-1.5 pr-3 py-1 rounded-md shadow-sm border transition-all focus:outline-none focus:ring-2 focus:ring-sky-500 focus:ring-offset-1 ${isProfileOpen ? 'bg-slate-50 border-slate-300' : 'bg-white border-slate-200 hover:bg-slate-50'
                                    }`}
                            >
                                <div className="flex items-center justify-center w-6 h-6 rounded bg-slate-900 text-xs font-bold text-white shadow-sm">
                                    A
                                </div>
                                <span className="text-xs font-semibold text-slate-700 group-hover:text-slate-900">
                                    Cmdr. Alex
                                </span>
                            </button>

                            {/* Profile Context Menu */}
                            {isProfileOpen && (
                                <div className="absolute right-0 mt-2 w-48 bg-white border border-slate-200 rounded-md shadow-lg py-1 z-50">
                                    <div className="px-4 py-2 border-b border-slate-100 mb-1">
                                        <p className="text-[12px] font-semibold text-slate-400">Logged in as</p>
                                        <p className="text-xs font-bold text-slate-900 truncate">Cmdr. Alex (NCPOR)</p>
                                    </div>
                                    <button className="w-full text-left px-4 py-2 text-xs font-medium text-slate-700 hover:bg-slate-50 flex items-center gap-2">
                                        <ShieldCheck size={14} className="text-slate-400" /> System Diagnostics
                                    </button>
                                    <button className="w-full text-left px-4 py-2 text-xs font-medium text-slate-700 hover:bg-slate-50 flex items-center gap-2">
                                        <Settings size={14} className="text-slate-400" /> Account Settings
                                    </button>
                                    <div className="border-t border-slate-100 mt-1 pt-1">
                                        <button onClick={logout} className="w-full text-left px-4 py-2 text-xs font-bold text-rose-600 hover:bg-rose-50 flex items-center gap-2 transition-colors">
                                            <LogOut size={14} /> End Secure Session
                                        </button>
                                    </div>
                                </div>
                            )}
                        </div>
                    </div>
                </header>

                {/* Page Content */}
                <div
                    className="flex-1 overflow-auto p-6 bg-slate-50"
                    // Close dropdowns if the user clicks anywhere in the main content area
                    onClick={() => { setIsNotifOpen(false); setIsProfileOpen(false); }}
                >
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
                }`
            }
        >
            <div className="flex items-center gap-3">
                {icon}
                {label}
            </div>
            {alert && <span className="w-2 h-2 rounded bg-rose-600"></span>}
        </NavLink>
    );
}

// Sub-component: Notification Item for the Popover
function NotificationItem({ icon, title, time, desc, unread }) {
    return (
        <div className={`px-4 py-3 border-b border-slate-50 hover:bg-slate-50 cursor-pointer transition-colors ${unread ? 'bg-slate-50/50' : ''}`}>
            <div className="flex items-start gap-3">
                <div className={`mt-0.5 p-1.5 rounded-md border ${unread ? 'bg-white border-slate-200 shadow-sm' : 'bg-slate-50 border-transparent'}`}>
                    {icon}
                </div>
                <div>
                    <div className="flex justify-between items-center gap-4">
                        <h5 className={`text-xs font-bold ${unread ? 'text-slate-900' : 'text-slate-700'}`}>{title}</h5>
                        <span className="text-[9px] font-medium text-slate-400">{time}</span>
                    </div>
                    <p className="text-[11px] text-slate-500 mt-0.5 leading-snug">{desc}</p>
                </div>
            </div>
        </div>
    );
}