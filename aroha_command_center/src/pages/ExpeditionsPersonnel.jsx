import React from 'react';
import DashboardLayout from '../components/layout/DashboardLayout';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { Users, Map, Tent, Calendar, TrendingUp, Navigation, UserCheck } from 'lucide-react';

// Mock data: Visualizing D_total = D_baseline + D_exp (from the ML doc)
const demandImpactData = [
    { day: 'Day 1', baseline: 120, expedition: 0 },
    { day: 'Day 5', baseline: 125, expedition: 0 },
    { day: 'Day 10', baseline: 122, expedition: 80 }, // Expedition starts
    { day: 'Day 15', baseline: 120, expedition: 85 },
    { day: 'Day 20', baseline: 128, expedition: 80 },
    { day: 'Day 25', baseline: 124, expedition: 0 },  // Expedition ends
    { day: 'Day 30', baseline: 121, expedition: 0 },
];

export default function ExpeditionsPersonnel() {
    return (
        <DashboardLayout>
            <div className="max-w-[1400px] mx-auto">

                {/* Page Header */}
                <div className="flex justify-between items-end mb-6">
                    <div>
                        <h1 className="text-2xl font-bold text-slate-900 mb-1">Expeditions & Personnel</h1>
                        <p className="text-sm text-slate-500">Tracking field rosters and calculating expedition-aware demand spikes.</p>
                    </div>
                    <button className="bg-[#6D28D9] text-white px-5 py-2.5 rounded-xl text-sm font-semibold shadow-md shadow-purple-900/20 hover:bg-purple-700 transition-colors">
                        + Plan New Expedition
                    </button>
                </div>

                {/* Top KPI Row */}
                <div className="grid grid-cols-4 gap-6 mb-6">
                    <KpiCard title="Active Field Expeditions" value="3" subtitle="Bharati & Maitri Regions" icon={<Map size={20} className="text-purple-600" />} bg="bg-purple-100" />
                    <KpiCard title="Personnel Deployed" value="42" subtitle="Active researchers & crew" icon={<Users size={20} className="text-blue-600" />} bg="bg-blue-100" />
                    <KpiCard title="Added Demand Load" value="+85" suffix="kg/day" subtitle="Peak expedition requirement" icon={<TrendingUp size={20} className="text-red-600" />} bg="bg-red-100" />
                    <KpiCard title="Upcoming Departures" value="1" subtitle="In next 14 days" icon={<Calendar size={20} className="text-emerald-600" />} bg="bg-emerald-100" />
                </div>

                {/* Middle Row: Demand Chart & Active Team Info */}
                <div className="grid grid-cols-12 gap-6 mb-6">

                    {/* Left: Expedition Demand Chart */}
                    <div className="col-span-8 bg-white rounded-2xl p-6 shadow-sm border border-slate-100 flex flex-col">
                        <div className="mb-6">
                            <h3 className="text-base font-bold text-slate-800">Expedition-Aware Demand Forecast</h3>
                            <p className="text-xs text-slate-500 mt-1">
                                Visualizing Baseline Demand ({"$D_{baseline}$"}) vs. Additional Expedition Requirement ({"$D_{exp}$"}).
                            </p>
                        </div>
                        <div className="flex-1 w-full min-h-[220px]">
                            <ResponsiveContainer width="100%" height="100%">
                                <AreaChart data={demandImpactData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                                    <defs>
                                        <linearGradient id="colorBaseline" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="5%" stopColor="#94a3b8" stopOpacity={0.3} />
                                            <stop offset="95%" stopColor="#94a3b8" stopOpacity={0} />
                                        </linearGradient>
                                        <linearGradient id="colorExpedition" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="5%" stopColor="#6D28D9" stopOpacity={0.6} />
                                            <stop offset="95%" stopColor="#6D28D9" stopOpacity={0} />
                                        </linearGradient>
                                    </defs>
                                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                                    <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#94a3b8' }} dy={10} />
                                    <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#94a3b8' }} />
                                    <Tooltip contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }} />
                                    <Area type="monotone" dataKey="baseline" name="Baseline Load" stroke="#94a3b8" fillOpacity={1} fill="url(#colorBaseline)" />
                                    <Area type="monotone" dataKey="expedition" name="Expedition Load" stroke="#6D28D9" fillOpacity={1} fill="url(#colorExpedition)" />
                                </AreaChart>
                            </ResponsiveContainer>
                        </div>
                    </div>

                    {/* Right: Expedition Snapshot */}
                    <div className="col-span-4 bg-gradient-to-br from-slate-900 to-[#1A103C] rounded-2xl p-6 text-white shadow-lg relative overflow-hidden flex flex-col justify-between">
                        <div className="absolute top-0 right-0 w-32 h-32 bg-purple-500/10 rounded-full blur-2xl"></div>

                        <div>
                            <div className="flex items-center justify-between mb-4">
                                <div className="flex items-center gap-2 text-purple-200 text-sm font-medium">
                                    <Tent size={16} className="text-purple-400" /> Active Mission
                                </div>
                                <span className="bg-emerald-500/20 text-emerald-300 text-[10px] font-bold px-2 py-1 rounded-md uppercase tracking-wider">In Progress</span>
                            </div>
                            <h2 className="text-2xl font-bold text-white tracking-tight mb-1">EXP-2026-03</h2>
                            <p className="text-sm text-slate-300">Deep Ice Core Drilling Team</p>
                        </div>

                        <div className="space-y-4 mt-6">
                            <div className="flex items-center gap-3 text-sm">
                                <Users size={16} className="text-purple-400" />
                                <span className="text-slate-300">Team Size: <strong className="text-white">12 Members</strong></span>
                            </div>
                            <div className="flex items-center gap-3 text-sm">
                                <Calendar size={16} className="text-purple-400" />
                                <span className="text-slate-300">Duration: <strong className="text-white">15 Days Remaining</strong></span>
                            </div>
                            <div className="flex items-center gap-3 text-sm">
                                <Navigation size={16} className="text-purple-400" />
                                <span className="text-slate-300">Base: <strong className="text-white">Maitri Station</strong></span>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Bottom Row: Personnel Roster Table */}
                <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
                    <div className="flex justify-between items-center mb-6">
                        <h3 className="text-base font-bold text-slate-800">Personnel Movement & Roster</h3>
                        <div className="flex gap-2">
                            <select className="text-xs bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 text-slate-600 outline-none font-medium">
                                <option>All Personnel</option>
                                <option>Deployed in Field</option>
                                <option>At Station</option>
                            </select>
                        </div>
                    </div>

                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="text-[11px] font-semibold text-slate-400 border-b border-slate-100 uppercase tracking-wider">
                                <th className="pb-3 font-medium">Personnel Name</th>
                                <th className="pb-3 font-medium">Role</th>
                                <th className="pb-3 font-medium">Current Location</th>
                                <th className="pb-3 font-medium">Assigned Expedition</th>
                                <th className="pb-3 font-medium text-right">Status</th>
                            </tr>
                        </thead>
                        <tbody className="text-sm text-slate-700">
                            <TableRow name="Dr. A. Sharma" role="Glaciologist" location="Field Camp Alpha" exp="EXP-2026-03" status="Active Field" />
                            <TableRow name="Eng. S. Kumar" role="Mechanic / Tech" location="Bharati Station" exp="None" status="Stationed" />
                            <TableRow name="P. Reddy" role="Logistics Lead" location="Field Camp Alpha" exp="EXP-2026-03" status="Active Field" />
                            <TableRow name="Dr. V. Menon" role="Medical Officer" location="Maitri Station" exp="EXP-2026-04 (Upcoming)" status="Preparing" />
                        </tbody>
                    </table>
                </div>
            </div>
        </DashboardLayout>
    );
}

// Sub-components
function KpiCard({ title, value, suffix, subtitle, icon, bg }) {
    return (
        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm flex items-center gap-4">
            <div className={`p-3 rounded-xl ${bg}`}>
                {icon}
            </div>
            <div>
                <h3 className="text-xs font-medium text-slate-500 mb-0.5">{title}</h3>
                <div className="text-2xl font-bold text-slate-800 leading-none">
                    {value}<span className="text-sm font-medium text-slate-400 ml-1">{suffix}</span>
                </div>
                {subtitle && <p className="text-[10px] text-slate-400 mt-1">{subtitle}</p>}
            </div>
        </div>
    );
}

function TableRow({ name, role, location, exp, status }) {
    const isField = status === 'Active Field';
    const statusColors = isField ? 'text-purple-700 bg-purple-50 border-purple-200' :
        (status === 'Stationed' ? 'text-emerald-700 bg-emerald-50 border-emerald-200' : 'text-amber-700 bg-amber-50 border-amber-200');

    return (
        <tr className="border-b border-slate-50 hover:bg-slate-50/50 transition-colors">
            <td className="py-4">
                <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center text-slate-500">
                        <UserCheck size={14} />
                    </div>
                    <div className="font-semibold text-slate-800">{name}</div>
                </div>
            </td>
            <td className="py-4 text-slate-500">{role}</td>
            <td className="py-4 font-medium text-slate-700">{location}</td>
            <td className="py-4">
                <span className={`font-mono text-xs ${exp !== 'None' ? 'text-slate-800 font-semibold' : 'text-slate-400'}`}>{exp}</span>
            </td>
            <td className="py-4 text-right">
                <span className={`px-2.5 py-1 rounded-md text-[10px] font-bold uppercase tracking-wider border ${statusColors}`}>
                    {status}
                </span>
            </td>
        </tr>
    );
}