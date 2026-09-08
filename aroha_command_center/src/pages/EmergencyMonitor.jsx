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
            <h1 className="text-2xl font-bold text-slate-900 mb-1">Burst Channel Monitor</h1>
            <p className="text-sm text-slate-500">High-priority emergency escalation and personnel extraction tracking.</p>
          </div>
          <div className="flex items-center gap-3 bg-red-50 text-red-700 px-4 py-2 rounded-xl border border-red-200">
            <Radio size={16} className="animate-pulse" />
            <span className="text-sm font-bold tracking-wide uppercase">Burst Channel: Active</span>
          </div>
        </div>

        {/* Top KPI Row */}
        <div className="grid grid-cols-4 gap-6 mb-6">
          <KpiCard title="Active Escalations" value="1" subtitle="Requires immediate action" icon={<AlertTriangle size={20} className="text-red-600"/>} bg="bg-red-100" alert />
          <KpiCard title="Nearest Response Node" value="Maitri" subtitle="ETA: 4 Hours (Helo)" icon={<Activity size={20} className="text-purple-600"/>} bg="bg-purple-100" />
          <KpiCard title="Personnel at Risk" value="4" subtitle="Field Camp Alpha" icon={<Users size={20} className="text-amber-600"/>} bg="bg-amber-100" />
          <KpiCard title="Avg. Resolution Time" value="11.2" suffix="hrs" subtitle="Historical YTD" icon={<Clock size={20} className="text-blue-600"/>} bg="bg-blue-100" />
        </div>

        {/* Middle Row: Active Emergency Banner */}
        <div className="bg-gradient-to-r from-[#7f1d1d] to-[#991b1b] rounded-2xl p-8 text-white shadow-xl mb-6 relative overflow-hidden flex justify-between items-center border border-red-900">
          <div className="absolute top-0 right-0 w-64 h-64 bg-red-500/20 rounded-full blur-3xl -translate-y-1/2 translate-x-1/4"></div>
          
          <div className="relative z-10 flex gap-6 items-center">
             <div className="w-16 h-16 bg-white/10 rounded-2xl flex items-center justify-center border border-white/20">
                <ShieldAlert size={32} className="text-red-300 animate-pulse" />
             </div>
             <div>
                <div className="flex items-center gap-3 mb-2">
                   <span className="bg-red-500 text-white text-[10px] font-bold px-2 py-1 rounded-md uppercase tracking-wider">Critical Priority</span>
                   <span className="text-red-200 text-sm font-mono">ID: BURST-2026-092</span>
                </div>
                <h2 className="text-2xl font-bold tracking-tight mb-1">Severe Generator Failure (Code 4)</h2>
                <p className="text-red-200/80 text-sm">Field Camp Alpha (Expedition EXP-2026-03) has lost primary and secondary heating power. Ambient temperature dropping rapidly.</p>
             </div>
          </div>
          
          <div className="relative z-10 flex flex-col gap-3 min-w-[200px]">
             <button className="w-full bg-white text-red-900 px-5 py-2.5 rounded-xl text-sm font-bold shadow-md hover:bg-red-50 transition-colors flex items-center justify-between">
               Deploy Response <ArrowRightCircle size={18} />
             </button>
             <button className="w-full bg-red-900/50 border border-red-500/50 text-white px-5 py-2.5 rounded-xl text-sm font-medium shadow-sm hover:bg-red-800 transition-colors">
               View Roster (12)
             </button>
          </div>
        </div>

        {/* Bottom Row: Emergency Log */}
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
           <div className="flex justify-between items-center mb-6">
              <h3 className="text-base font-bold text-slate-800">Historical Emergency Log</h3>
              <div className="flex gap-2">
                 <select className="text-xs bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 text-slate-600 outline-none font-medium">
                    <option>Last 30 Days</option>
                    <option>Year to Date</option>
                 </select>
              </div>
           </div>
           
           <table className="w-full text-left border-collapse">
            <thead>
              <tr className="text-[11px] font-semibold text-slate-400 border-b border-slate-100 uppercase tracking-wider">
                <th className="pb-3 font-medium">Event ID & Date</th>
                <th className="pb-3 font-medium">Location</th>
                <th className="pb-3 font-medium">Classification</th>
                <th className="pb-3 font-medium">Resolution</th>
                <th className="pb-3 font-medium text-right">Status</th>
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

// Sub-components
function KpiCard({ title, value, suffix, subtitle, icon, bg, alert }) {
  return (
    <div className={`bg-white p-5 rounded-2xl border ${alert ? 'border-red-200 shadow-[0_0_15px_rgba(239,68,68,0.1)]' : 'border-slate-100 shadow-sm'} flex items-center gap-4 relative overflow-hidden`}>
      {alert && <div className="absolute top-0 left-0 w-1 h-full bg-red-500"></div>}
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

function TableRow({ id, date, location, classification, resolution, status, alert }) {
  const statusColors = alert 
    ? 'text-red-700 bg-red-50 border-red-200 animate-pulse' 
    : 'text-slate-600 bg-slate-50 border-slate-200';

  return (
    <tr className="border-b border-slate-50 hover:bg-slate-50/50 transition-colors">
      <td className="py-4">
        <div className="font-semibold text-slate-800">{id}</div>
        <div className="text-[10px] text-slate-400 mt-0.5">{date}</div>
      </td>
      <td className="py-4 font-medium text-slate-600">{location}</td>
      <td className="py-4 text-slate-700">{classification}</td>
      <td className="py-4 text-slate-500 text-xs">{resolution}</td>
      <td className="py-4 text-right">
        <span className={`px-2.5 py-1 rounded-md text-[10px] font-bold uppercase tracking-wider border ${statusColors}`}>
          {status}
        </span>
      </td>
    </tr>
  );
}