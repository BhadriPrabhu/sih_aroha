import React, { useState } from 'react';
import DashboardLayout from '../components/layout/DashboardLayout';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { Users, Map, Tent, Calendar, TrendingUp, Navigation, UserCheck, Loader2, Check } from 'lucide-react';

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

    const [planState, setPlanState] = useState('idle');

    const handlePlanExpedition = () => {
        if (planState === 'running') return;
        setPlanState('running');
        setTimeout(() => {
            setPlanState('success');
            setTimeout(() => setPlanState('idle'), 3000);
        }, 1200);
    };

    return (
        <DashboardLayout>
            <div className="max-w-[1400px] mx-auto">

                {/* Page Header */}
                <div className="flex flex-col sm:flex-row sm:justify-between sm:items-end gap-4 mb-6">
                    <div>
                        <h1 className="text-xl sm:text-2xl font-bold text-slate-900 tracking-tight mb-1">Expeditions & Personnel</h1>
                        <p className="text-xs sm:text-sm font-medium text-slate-500">Tracking field rosters and calculating expedition-aware demand spikes.</p>
                    </div>
                    <button
                        onClick={handlePlanExpedition}
                        disabled={planState === 'running'}
                        className={`w-full sm:w-auto px-5 py-2.5 sm:py-2 rounded-md text-sm font-semibold shadow-sm transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 flex items-center justify-center min-w-[180px] ${planState === 'running' ? 'bg-slate-900 text-slate-500 cursor-not-allowed' :
                                planState === 'success' ? 'bg-emerald-600 text-white focus:ring-emerald-500' :
                                    'bg-slate-900 text-white hover:bg-slate-800 focus:ring-slate-800'
                            }`}
                    >
                        {planState === 'idle' && 'Plan New Expedition'}
                        {planState === 'running' && <><Loader2 size={14} className="animate-spin mr-2" /> Initializing...</>}
                        {planState === 'success' && <><Check size={14} className="mr-2" /> Planner Ready</>}
                    </button>
                </div>

                {/* Top KPI Row */}
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
                    <KpiCard title="Active Field Expeditions" value="3" subtitle="Bharati & Maitri Regions" icon={<Map size={18} />} />
                    <KpiCard title="Personnel Deployed" value="42" subtitle="Active researchers & crew" icon={<Users size={18} />} />
                    <KpiCard title="Added Demand Load" value="+85" suffix="kg/day" subtitle="Peak expedition requirement" icon={<TrendingUp size={18} />} alert />
                    <KpiCard title="Upcoming Departures" value="1" subtitle="In next 14 days" icon={<Calendar size={18} />} />
                </div>

                {/* Middle Row: Demand Chart & Active Team Info */}
                <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 mb-6">

                    {/* Left: Expedition Demand Chart */}
                    <div className="col-span-1 lg:col-span-8 bg-white rounded-lg p-4 sm:p-6 shadow-sm border border-slate-200 flex flex-col">
                        <div className="mb-6 border-b border-slate-100 pb-4">
                            <h3 className="text-base sm:text-lg font-bold text-slate-900">Expedition - Aware Demand Forecast</h3>
                            <p className="text-xs text-slate-500 mt-1 font-medium">
                                Visualizing Baseline Demand ({"$D_{baseline}$"}) vs. Additional Expedition Requirement ({"$D_{exp}$"}).
                            </p>
                        </div>
                        <div className="flex-1 w-full min-h-[220px]">
                            <ResponsiveContainer width="100%" height="100%">
                                <AreaChart data={demandImpactData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E2E8F0" />
                                    <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#64748B', fontWeight: 500 }} dy={10} />
                                    <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#64748B', fontWeight: 500 }} />
                                    <Tooltip contentStyle={{ borderRadius: '6px', border: '1px solid #E2E8F0', boxShadow: '0 1px 2px 0 rgb(0 0 0 / 0.05)' }} />
                                    <Area type="monotone" dataKey="baseline" name="Baseline Load" stroke="#64748B" strokeWidth={2} fillOpacity={0.1} fill="#64748B" />
                                    <Area type="monotone" dataKey="expedition" name="Expedition Load" stroke="#0284C7" strokeWidth={2} fillOpacity={0.1} fill="#0284C7" />
                                </AreaChart>
                            </ResponsiveContainer>
                        </div>
                    </div>

                    {/* Right: Expedition Snapshot */}
                    <div className="col-span-1 lg:col-span-4 bg-slate-900 border border-slate-800 rounded-lg p-6 text-white shadow-sm flex flex-col justify-between">
                        <div>
                            <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-4 mb-6 border-b border-slate-800 pb-4">
                                <div className="flex items-center gap-2 text-slate-400 text-lg font-semibold">
                                    <Tent size={16} className="text-sky-500" /> Active Mission
                                </div>
                                <span className="bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 text-[12px] font-bold px-2 py-0.5 rounded-sm self-start sm:self-auto">
                                    In Progress
                                </span>
                            </div>
                            <h2 className="text-2xl font-bold text-white tracking-tight mb-1">EXP-2026-03</h2>
                            <p className="text-sm text-slate-400 font-medium">Deep Ice Core Drilling Team</p>
                        </div>

                        <div className="space-y-4 mt-8 bg-slate-800/50 border border-slate-700/50 rounded-md p-4">
                            <div className="flex items-center gap-3 text-sm">
                                <Users size={16} className="text-sky-500 shrink-0" />
                                <span className="text-slate-400 font-medium">Team Size: <strong className="text-white ml-1">12 Members</strong></span>
                            </div>
                            <div className="flex items-center gap-3 text-sm">
                                <Calendar size={16} className="text-sky-500 shrink-0" />
                                <span className="text-slate-400 font-medium">Duration: <strong className="text-white ml-1">15 Days Remaining</strong></span>
                            </div>
                            <div className="flex items-center gap-3 text-sm">
                                <Navigation size={16} className="text-sky-500 shrink-0" />
                                <span className="text-slate-400 font-medium flex flex-wrap">Base: <strong className="text-white ml-1">Maitri Station</strong></span>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Bottom Row: Personnel Roster Table */}
                <div className="bg-white rounded-lg p-4 sm:p-6 shadow-sm border border-slate-200">
                    <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4 mb-6">
                        <h3 className="text-lg font-bold text-slate-900">Personnel Movement & Roster</h3>
                        <select className="w-full sm:w-auto text-xs font-medium bg-slate-50 border border-slate-200 rounded-md px-3 py-1.5 text-slate-700 outline-none focus:ring-1 focus:ring-sky-500">
                            <option>All Personnel</option>
                            <option>Deployed in Field</option>
                            <option>At Station</option>
                        </select>
                    </div>

                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse min-w-[700px]">
                            <thead>
                                <tr className="text-[12px] font-semibold text-slate-500 border-b border-slate-200 bg-slate-50">
                                    <th className="py-3 px-4 font-semibold rounded-tl-md">Personnel Name</th>
                                    <th className="py-3 px-4 font-semibold">Role</th>
                                    <th className="py-3 px-4 font-semibold">Current Location</th>
                                    <th className="py-3 px-4 font-semibold">Assigned Expedition</th>
                                    <th className="py-3 px-4 font-semibold text-right rounded-tr-md">Status</th>
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
            </div>
        </DashboardLayout>
    );
}

// Sub-components
function KpiCard({ title, value, suffix, subtitle, icon, alert }) {
    return (
        <div className={`bg-white p-4 sm:p-5 rounded-lg border ${alert ? 'border-rose-500 shadow-sm' : 'border-slate-200 shadow-sm'} flex items-start gap-3 sm:gap-4 relative overflow-hidden`}>
            {alert && <div className="absolute top-0 left-0 w-1 h-full bg-rose-600"></div>}
            <div className={`p-2 border rounded-md shrink-0 ${alert ? 'bg-rose-50 border-rose-200 text-rose-600' : 'bg-slate-50 border-slate-200 text-slate-600'}`}>
                {icon}
            </div>
            <div>
                <h3 className="text-[12px] font-semibold text-slate-500 mb-1 leading-tight">{title}</h3>
                <div className="text-xl sm:text-2xl font-bold text-slate-900 tracking-tight leading-none mt-1">
                    {value}<span className="text-sm font-medium text-slate-500 ml-1">{suffix}</span>
                </div>
                {subtitle && <p className="text-[11px] sm:text-[12px] text-slate-400 mt-1 sm:mt-1.5 font-medium leading-tight">{subtitle}</p>}
            </div>
        </div>
    );
}

function TableRow({ name, role, location, exp, status }) {
    // Tactical mapping for status colors
    const isField = status === 'Active Field';
    const isStationed = status === 'Stationed';

    const statusColors = isField ? 'text-sky-700 bg-sky-50 border-sky-200' :
        (isStationed ? 'text-emerald-700 bg-emerald-50 border-emerald-200' : 'text-amber-700 bg-amber-50 border-amber-200');

    return (
        <tr className="border-b border-slate-100 hover:bg-slate-50 transition-colors">
            <td className="py-3 px-4">
                <div className="flex items-center gap-3">
                    <div className="w-7 h-7 rounded border border-slate-200 bg-white flex items-center justify-center text-slate-500 shadow-sm shrink-0">
                        <UserCheck size={14} />
                    </div>
                    <div className="font-semibold text-slate-900 whitespace-nowrap">{name}</div>
                </div>
            </td>
            <td className="py-3 px-4 font-medium text-slate-600 whitespace-nowrap">{role}</td>
            <td className="py-3 px-4 font-medium text-slate-900 whitespace-nowrap">{location}</td>
            <td className="py-3 px-4">
                <span className={`font-mono text-xs whitespace-nowrap ${exp !== 'None' ? 'text-slate-800 font-semibold' : 'text-slate-400'}`}>{exp}</span>
            </td>
            <td className="py-3 px-4 text-right">
                <span className={`px-2 py-0.5 rounded text-[10px] font-semibold border whitespace-nowrap ${statusColors}`}>
                    {status}
                </span>
            </td>
        </tr>
    );
}