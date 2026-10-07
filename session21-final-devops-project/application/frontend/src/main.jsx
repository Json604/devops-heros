import React, {useEffect, useState} from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';

const states = ['OPEN', 'IN_PROGRESS', 'RESOLVED'];
const label = value => value.replaceAll('_', ' ').toLowerCase();

async function request(path, options = {}) {
  const response = await fetch(`/api/tickets${path}`, options);
  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    throw new Error(typeof body.detail === 'string' ? body.detail : `Request failed (${response.status})`);
  }
  return response.status === 204 ? null : response.json();
}

function App() {
  const [tickets, setTickets] = useState([]);
  const [filter, setFilter] = useState('ALL');
  const [search, setSearch] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);

  async function load() {
    setTickets(await request(''));
  }
  useEffect(() => {load().catch(e => setError(e.message)).finally(() => setLoading(false));}, []);

  async function mutate(action) {
    setBusy(true);
    setError('');
    try {await action(); await load();}
    catch (e) {setError(e.message);}
    finally {setBusy(false);}
  }

  function create(event) {
    event.preventDefault();
    const form = event.currentTarget;
    const payload = Object.fromEntries(new FormData(form));
    mutate(async () => {
      await request('', {method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(payload)});
      form.reset();
    });
  }

  const visible = tickets.filter(ticket => (filter === 'ALL' || ticket.status === filter) &&
    `${ticket.title} ${ticket.requester} ${ticket.category}`.toLowerCase().includes(search.toLowerCase()));

  return <div className="workspace">
    <header><div><p className="eyebrow">CAMPUS IT SERVICES</p><h1>Helpdesk</h1><p>Report campus IT issues and follow each request to resolution.</p></div><div className="identity"><strong>Kartikey</strong><span>24bcs10121</span></div></header>
    <main>
      <section className="summary" aria-label="Ticket summary">
        {['ALL', ...states].map(state => <button key={state} className={filter === state ? 'metric selected' : 'metric'} onClick={() => setFilter(state)} aria-pressed={filter === state}>
          <span>{state === 'ALL' ? 'All tickets' : label(state)}</span><strong>{state === 'ALL' ? tickets.length : tickets.filter(t => t.status === state).length}</strong>
        </button>)}
      </section>
      {error && <p className="error" role="alert">{error} <button onClick={() => mutate(load)}>Retry</button></p>}
      <div className="columns">
        <section className="panel tickets"><div className="section-head"><h2>Service requests</h2><label className="search">Search tickets<input value={search} onChange={e => setSearch(e.target.value)} placeholder="Title, requester or category" type="search"/></label></div>
          {loading ? <p role="status">Loading tickets…</p> : visible.length === 0 ? <div className="empty"><h3>No tickets here</h3><p>Create a request or choose another filter.</p></div> : <ul className="ticket-list">{visible.map(ticket => <li key={ticket.id}>
            <div className="ticket-heading"><span className="ticket-number">#{ticket.id}</span><span className={`priority ${ticket.priority.toLowerCase()}`}>{label(ticket.priority)} priority</span><span className="category">{label(ticket.category)}</span></div>
            <h3>{ticket.title}</h3><p className="description">{ticket.description || 'No additional details.'}</p>
            <p className="meta">Requested by {ticket.requester} · Assigned to {ticket.assignee}</p>
            <div className="ticket-actions"><label>Status<select aria-label={`Status for ticket ${ticket.id}`} value={ticket.status} disabled={busy} onChange={e => mutate(() => request(`/${ticket.id}`, {method:'PUT', headers:{'Content-Type':'application/json'}, body:JSON.stringify({status:e.target.value})}))}>{states.map(s => <option key={s} value={s}>{label(s)}</option>)}</select></label>
              <button className="delete" disabled={busy} onClick={() => {if (window.confirm(`Delete ticket #${ticket.id}?`)) mutate(() => request(`/${ticket.id}`, {method:'DELETE'}));}}>Delete</button></div>
          </li>)}</ul>}
        </section>
        <section className="panel compose"><p className="eyebrow">NEW REQUEST</p><h2>What needs fixing?</h2><form onSubmit={create}>
          <label>Title<input name="title" required minLength={1} maxLength={200} placeholder="e.g. Wi-Fi unavailable in Lab 3"/></label>
          <label>Details<textarea name="description" maxLength={4000} rows={4} placeholder="Location, symptoms and when it started"/></label>
          <label>Category<select name="category">{['NETWORK','HARDWARE','SOFTWARE','ACCOUNT','OTHER'].map(c => <option key={c} value={c}>{label(c)}</option>)}</select></label>
          <label>Priority<select name="priority" defaultValue="MEDIUM">{['LOW','MEDIUM','HIGH'].map(p => <option key={p} value={p}>{label(p)}</option>)}</select></label>
          <label>Requester<input name="requester" defaultValue="24bcs10121" required maxLength={120}/></label>
          <label>Assign to<input name="assignee" defaultValue="Unassigned" required maxLength={120}/></label>
          <button className="primary" disabled={busy}>{busy ? 'Saving…' : 'Create ticket'}</button>
        </form></section>
      </div>
    </main><footer>Campus Helpdesk · DevOps project · Kartikey / 24bcs10121</footer>
  </div>;
}

createRoot(document.getElementById('root')).render(<App/>);
