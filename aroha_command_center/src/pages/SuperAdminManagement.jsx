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
                <div className="flex flex-col sm:flex-row sm:justify-between sm:items-end gap-4 mb-6">
                    <div>
                        <div className="flex items-center gap-2">
                            <ShieldAlert size={18} className="text-rose-600" />
                            <h1 className="text-xl sm:text-2xl font-bold text-slate-900 tracking-tight">Access Control & Telemetry</h1>
                        </div>
                        <p className="text-xs font-medium text-slate-500 tracking-wider mt-1">Super Admin Privilege: Personnel role management and active session tracking.</p>
                    </div>
                    <button className="w-full sm:w-auto bg-slate-900 text-white px-5 py-2 rounded-md text-sm font-semibold shadow-sm hover:bg-slate-800 transition-colors flex items-center justify-center gap-2 focus:outline-none focus:ring-2 focus:ring-slate-900 focus:ring-offset-2">
                        <UserPlus size={16} /> Provision New Operator
                    </button>
                </div>

                {/* Operator Management Table Container */}
                <div className="bg-white rounded-lg p-4 sm:p-6 shadow-sm border border-slate-200">
                    <div className="flex flex-col lg:flex-row lg:justify-between items-start lg:items-center gap-4 mb-6">
                        <h3 className="text-lg sm:text-xl font-bold text-slate-900 tracking-tight">Global Operator Registry</h3>
                        
                        <div className="flex flex-col sm:flex-row gap-2 w-full lg:w-auto">
                            <input 
                                type="text" 
                                placeholder="Search ID or Name..." 
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                                className="w-full sm:w-64 text-sm font-medium bg-slate-50 border border-slate-200 rounded-md px-3 py-1.5 text-slate-700 outline-none focus:ring-1 focus:ring-sky-500"
                            />
                            <select className="w-full sm:w-auto text-xs font-medium bg-slate-50 border border-slate-200 rounded-md px-3 py-1.5 text-slate-700 outline-none focus:ring-1 focus:ring-sky-500">
                                <option>All Roles</option>
                                <option>SUPER_ADMIN</option>
                                <option>ADMIN</option>
                                <option>MANAGER</option>
                            </select>
                        </div>
                    </div>
                    
                    {/* Horizontal scroll container for the table to prevent mobile breakage */}
                    <div className="overflow-x-auto w-full">
                        <table className="w-full text-left border-collapse min-w-[800px]">
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
            </div>
        </DashboardLayout>
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
            
            <td className="py-3 px-4">
                <span className={`px-2.5 py-1 rounded-md text-xs font-bold`}>
                    {formatRole(role)}
                </span>
            </td>
            
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