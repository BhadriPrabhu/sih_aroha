import React from 'react';
import DashboardLayout from '../components/layout/DashboardLayout';
import { AlertTriangle, Radio, ShieldAlert, Activity, Users, Clock, ArrowRightCircle } from 'lucide-react';

export default function EmergencyMonitor() {
  return (
    <DashboardLayout>
      <div className="max-w-[1400px] mx-auto">
        
        {/* Page Header */}
        <div className="flex justify-between items-end mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight mb-1">Burst Channel Monitor</h1>
            <p className="text-xs font-medium text-slate-500 uppercase tracking-wider">High-priority emergency escalation and personnel extraction tracking.</p>
          </div>
          <div className="flex items-center gap-2 bg-rose-50 text-rose-700 px-3 py-1.5 rounded-md border border-rose-200">
            <Radio size={14} className="animate-pulse" />
            <span className="text-[10px] font-bold tracking-widest uppercase">Burst Channel: Active</span>
          </div>
        </div>

        {/* Top KPI Row */}
        <div className="grid grid-cols-4 gap-4 mb-6">
          <KpiCard title="Active Escalations" value="1" subtitle="Requires immediate action" icon={<AlertTriangle size={18} className="text-rose-600"/>} alert />
          <KpiCard title="Nearest Response Node" value="Maitri" subtitle="ETA: 4 Hours (Helo)" icon={<Activity size={18} className="text-slate-600"/>} />
          <KpiCard title="Personnel at Risk" value="4" subtitle="Field Camp Alpha" icon={<Users size={18} className="text-slate-600"/>} />
          <KpiCard title="Avg. Resolution Time" value="11.2" suffix="hrs" subtitle="Historical YTD" icon={<Clock size={18} className="text-slate-600"/>} />
        </div>

        {/* Middle Row: Active Emergency Banner (Tactical Dark Slate + Crimson) */}
        <div className="bg-slate-900 border border-rose-600 border-l-4 rounded-lg p-6 shadow-sm mb-6 flex justify-between items-center">
          
          <div className="flex gap-5 items-center">
             <div className="p-3 bg-rose-500/10 border border-rose-500/20 rounded-md text-rose-500">
                <ShieldAlert size={28} className="animate-pulse" />
             </div>
             <div>
                <div className="flex items-center gap-3 mb-1.5">
                   <span className="bg-rose-600 text-white text-[10px] font-bold px-2 py-0.5 rounded-sm uppercase tracking-wider">Critical Priority</span>
                   <span className="text-slate-400 text-xs font-mono font-medium">ID: BURST-2026-092</span>
                </div>
                <h2 className="text-xl font-bold text-white tracking-tight mb-1">Severe Generator Failure (Code 4)</h2>
                <p className="text-slate-400 text-sm">Field Camp Alpha (Expedition EXP-2026-03) has lost primary and secondary heating power. Ambient temperature dropping rapidly.</p>
             </div>
          </div>
          
          <div className="flex flex-col gap-2 min-w-[220px]">
             <button className="w-full bg-rose-600 text-white px-4 py-2 rounded-md text-sm font-bold shadow-sm hover:bg-rose-700 transition-colors flex items-center justify-between focus:outline-none focus:ring-2 focus:ring-rose-500 focus:ring-offset-2 focus:ring-offset-slate-900">
               Deploy Response <ArrowRightCircle size={16} />
             </button>
             <button className="w-full bg-transparent border border-slate-700 text-slate-300 px-4 py-2 rounded-md text-sm font-semibold hover:bg-slate-800 hover:text-white transition-colors">
               View Roster (12)
             </button>
          </div>
        </div>

        {/* Bottom Row: Emergency Log */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-slate-200">
           <div className="flex justify-between items-center mb-6">
              <h3 className="text-sm font-bold text-slate-900 tracking-tight uppercase">Historical Emergency Log</h3>
              <select className="text-xs font-medium bg-slate-50 border border-slate-200 rounded-md px-3 py-1.5 text-slate-700 outline-none focus:ring-1 focus:ring-sky-500">
                <option>Last 30 Days</option>
                <option>Year to Date</option>
              </select>
           </div>
           
           <table className="w-full text-left border-collapse">
            <thead>
              <tr className="text-[10px] font-bold text-slate-500 border-b border-slate-200 uppercase tracking-wider bg-slate-50">
                <th className="py-3 px-4 rounded-tl-md">Event ID & Date</th>
                <th className="py-3 px-4">Location</th>
                <th className="py-3 px-4">Classification</th>
                <th className="py-3 px-4">Resolution</th>
                <th className="py-3 px-4 text-right rounded-tr-md">Status</th>
              </tr>
            </thead>
            <tbody className="text-sm text-slate-700">
              <TableRow 
                id="BURST-2026-092" date="Today, 08:14 UTC" location="Field Camp Alpha" 
                classification="Power/Heating Failure" resolution="Awaiting Deployment" status="Active" alert
              />
              <TableRow 
                id="BURST-2026-088" date="12 Sep 2026" location="Bharati Station" 
                classification="Medical (Trauma)" resolution="Medevac to Cape Town" status="Resolved" 
              />
              <TableRow 
                id="BURST-2026-041" date="03 Jul 2026" location="Maitri Station" 
                classification="Comms Blackout" resolution="Secondary SATCOM reboot" status="Resolved" 
              />
            </tbody>
          </table>
        </div>
      </div>
    </DashboardLayout>
  );
}

// Sub-components - REFACTORED FOR CRISP GEOMETRY AND MONOTONE ICONS
function KpiCard({ title, value, suffix, subtitle, icon, alert }) {
  return (
    <div className={`bg-white p-5 rounded-lg border ${alert ? 'border-rose-500 shadow-sm' : 'border-slate-200 shadow-sm'} flex items-start gap-4 relative overflow-hidden`}>
      {alert && <div className="absolute top-0 left-0 w-1 h-full bg-rose-600"></div>}
      <div className={`p-2 border rounded-md ${alert ? 'bg-rose-50 border-rose-200' : 'bg-slate-50 border-slate-200 text-slate-600'}`}>
        {icon}
      </div>
      <div>
        <h3 className="text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1">{title}</h3>
        <div className="text-2xl font-bold text-slate-900 tracking-tight leading-none">
          {value}<span className="text-sm font-medium text-slate-500 ml-1">{suffix}</span>
        </div>
        {subtitle && <p className="text-[10px] text-slate-400 mt-2 font-medium uppercase">{subtitle}</p>}
      </div>
    </div>
  );
}

function TableRow({ id, date, location, classification, resolution, status, alert }) {
  const statusColors = alert 
    ? 'text-rose-700 bg-rose-50 border-rose-200' 
    : 'text-slate-600 bg-slate-50 border-slate-200';

  return (
    <tr className="border-b border-slate-100 hover:bg-slate-50 transition-colors">
      <td className="py-3 px-4">
        <div className="font-mono text-xs font-semibold text-slate-900">{id}</div>
        <div className="text-[10px] font-medium text-slate-500 mt-0.5 uppercase">{date}</div>
      </td>
      <td className="py-3 px-4 font-medium text-slate-600">{location}</td>
      <td className="py-3 px-4 text-slate-700 font-medium">{classification}</td>
      <td className="py-3 px-4 text-slate-500 text-xs">{resolution}</td>
      <td className="py-3 px-4 text-right">
        <span className={`px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider border ${statusColors} ${alert ? 'animate-pulse' : ''}`}>
          {status}
        </span>
      </td>
    </tr>
  );
}