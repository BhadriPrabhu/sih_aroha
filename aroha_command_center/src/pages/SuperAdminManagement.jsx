import React, { useState } from 'react';
import DashboardLayout from '../components/layout/DashboardLayout';
import { ShieldAlert, Users, Activity, Key, Edit, Trash2, UserPlus, Server } from 'lucide-react';

// Mock User Database
const mockUsers = [
    { id: 'USR-001', name: 'Dr. C. Sharma', role: 'SUPER_ADMIN', email: 'director@ncpor.res.in', status: 'Online', lastActive: 'Now' },
    { id: 'USR-042', name: 'Cmdr. Alex', role: 'ADMIN', email: 'alex.logistics@ncpor.res.in', status: 'Online', lastActive: '2 mins ago' },
    { id: 'USR-118', name: 'Station Cmdr. Rao', role: 'MANAGER', email: 'rao.bharati@ncpor.res.in', status: 'Offline', lastActive: '4 hrs ago' },
    { id: 'USR-205', name: 'Dr. V. Menon', role: 'EMPLOYEE', email: 'v.menon.med@ncpor.res.in', status: 'Online', lastActive: '12 mins ago' },
    { id: 'USR-311', name: 'Field Op. Singh', role: 'USER', email: 'singh.f1@ncpor.res.in', status: 'Offline', lastActive: '1 day ago' },
];

export default function SuperAdminManagement() {
    const [search, setSearch] = useState('');

    return (
        <DashboardLayout>
            <div className="max-w-[1400px] mx-auto">
                
                {/* Page Header */}
                <div className="flex justify-between items-end mb-4">
                    <div>
                        <div className="flex items-center gap-2">
                            <ShieldAlert size={18} className="text-rose-600" />
                            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Access Control & Telemetry</h1>
                        </div>
                        <p className="text-xs font-medium text-slate-500 tracking-wider">Super Admin Privilege: Personnel role management and active session tracking.</p>
                    </div>
                    <button className="bg-slate-900 text-white px-5 py-2 rounded-md text-sm font-semibold shadow-sm hover:bg-slate-800 transition-colors flex items-center gap-2 focus:outline-none focus:ring-2 focus:ring-slate-900 focus:ring-offset-2">
                        <UserPlus size={16} /> Provision New Operator
                    </button>
                </div>

                {/* Top KPI Row
                <div className="grid grid-cols-4 gap-4 mb-6">
                    <KpiCard title="Total Registered IDs" value="1,204" icon={<Users size={18} />} />
                    <KpiCard title="Active Sessions (SATCOM)" value="42" subtitle="Live connections" icon={<Activity size={18} className="text-emerald-600" />} alertState="positive" />
                    <KpiCard title="Super Admin Nodes" value="3" subtitle="Root access granted" icon={<Key size={18} className="text-rose-600" />} alertState="critical" />
                    <KpiCard title="Network Auth Gateway" value="Stable" subtitle="Latency: 45ms" icon={<Server size={18} />} />
                </div> */}

                {/* Operator Management Table */}
                <div className="bg-white rounded-lg p-4 shadow-sm border border-slate-200">
                    <div className="flex justify-between mb-4 items-center">
                        <h3 className="text-xl font-bold text-slate-900 tracking-tight">Global Operator Registry</h3>
                        <div className="flex gap-2">
                            <input 
                                type="text" 
                                placeholder="Search ID or Name..." 
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                                className="text-sm font-medium bg-slate-50 border border-slate-200 rounded-md px-3 py-1.5 text-slate-700 outline-none focus:ring-1 focus:ring-sky-500 w-64"
                            />
                            <select className="text-xs font-medium bg-slate-50 border border-slate-200 rounded-md px-3 py-1.5 text-slate-700 outline-none focus:ring-1 focus:ring-sky-500">
                                <option>All Roles</option>
                                <option>SUPER_ADMIN</option>
                                <option>ADMIN</option>
                                <option>MANAGER</option>
                            </select>
                        </div>
                    </div>
                    
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="text-[10px] font-bold text-slate-500 border-b border-slate-200 uppercase tracking-wider bg-slate-50">
                                <th className="py-3 px-4 rounded-tl-md">Operator ID & Name</th>
                                <th className="py-3 px-4">Network Role</th>
                                <th className="py-3 px-4">Session Status</th>
                                <th className="py-3 px-4">Last Activity</th>
                                <th className="py-3 px-4 text-right rounded-tr-md">Clearance Actions</th>
                            </tr>
                        </thead>
                        <tbody className="text-sm text-slate-700">
                            {mockUsers.map(user => (
                                <TableRow key={user.id} {...user} />
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </DashboardLayout>
    );
}

function KpiCard({ title, value, subtitle, icon, alertState }) {
    const isCritical = alertState === 'critical';
    const isPositive = alertState === 'positive';
    
    return (
        <div className={`bg-white p-5 rounded-lg border ${isCritical ? 'border-rose-500' : isPositive ? 'border-emerald-500' : 'border-slate-200'} shadow-sm flex items-start gap-4`}>
            <div className={`p-2 border rounded-md ${isCritical ? 'bg-rose-50 border-rose-200 text-rose-600' : isPositive ? 'bg-emerald-50 border-emerald-200 text-emerald-600' : 'bg-slate-50 border-slate-200 text-slate-600'}`}>
                {icon}
            </div>
            <div>
                <h3 className="text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1">{title}</h3>
                <div className="text-2xl font-bold text-slate-900 tracking-tight leading-none">{value}</div>
                {subtitle && <p className="text-[10px] text-slate-400 mt-2 font-medium uppercase tracking-wider">{subtitle}</p>}
            </div>
        </div>
    );
}

function TableRow({ id, name, role, email, status, lastActive }) {
    const isOnline = status === 'Online';

    // Helper to format "SUPER_ADMIN" into "Super Admin"
    const formatRole = (r) => {
        return r.split('_').map(word => word.charAt(0) + word.slice(1).toLowerCase()).join(' ');
    };

    return (
        <tr className="border-b border-slate-100 hover:bg-slate-50 transition-colors">
            <td className="py-3 px-4">
                <div className="font-semibold text-slate-900">{name}</div>
                <div className="flex items-center gap-2 mt-0.5">
                    <span className="font-mono text-[10px] text-slate-500 uppercase">{id}</span>
                    <span className="text-[10px] text-slate-400">{email}</span>
                </div>
            </td>
            
            {/* UPDATED: Network Role Column */}
            <td className="py-3 px-4">
                <span className={`px-2.5 py-1 rounded-md text-xs font-bold`}>
                    {formatRole(role)}
                </span>
            </td>
            
            {/* UPDATED: Session Status Column */}
            <td className="py-3 px-4">
                <div className="flex items-center gap-2">
                    <div className={`w-1.5 h-1.5 rounded-full ${isOnline ? 'bg-green-500' : 'bg-slate-300'}`}></div>
                    <span className="text-sm text-slate-600">{status}</span>
                </div>
            </td>
            
            <td className="py-3 px-4 text-sm text-slate-500">{lastActive}</td>
            <td className="py-3 px-4 text-right">
                <div className="flex items-center justify-end gap-3">
                    <button className="text-slate-400 hover:text-blue-600 transition-colors" title="Edit Permissions">
                        <Edit size={16} />
                    </button>
                    <button className="text-slate-400 hover:text-red-600 transition-colors" title="Revoke Access">
                        <Trash2 size={16} />
                    </button>
                </div>
            </td>
        </tr>
    );
}