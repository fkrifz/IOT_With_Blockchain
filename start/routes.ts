/*
|--------------------------------------------------------------------------
| Routes
|--------------------------------------------------------------------------
|
| This file is dedicated for defining HTTP routes. A single file is enough
| for majority of projects, however you can define routes in different
| files and just make sure to import them inside this file. For example
|
| Define routes in following two files
| ├── start/routes/cart.ts
| ├── start/routes/customer.ts
|
| and then import them inside `start/routes.ts` as follows
|
| import './routes/cart'
| import './routes/customer''
|
*/

import Route from '@ioc:Adonis/Core/Route'
import IdentitasPerangkat from '../app/Models/IdentitasPerangkat'

Route.get('/', async ({ view }) => {
  return view.render('pages/index')
})

Route.get('/login', async ({ view }) => {
  return view.render('pages/auth/login')
})

Route.post('/login', async ({ auth, request, response }) => {
  const email = request.input('email')
  const password = request.input('password')

  try {
    await auth.use('web').attempt(email, password)
    response.redirect('/admin')
  } catch {
    return response.badRequest('Invalid credentials')
  }
}).as('login')

Route.post('/logout', async ({ auth, response }) => {
  await auth.use('web').logout()
  response.redirect('/login')
}).as('logout')

Route.post('/admin/device/create', async ({auth, response, request, session}) => {
  const nama_perangkat = request.input('nama_perangkat')
  const lokasi_perangkat = request.input('lokasi_perangkat')

  try {
    await IdentitasPerangkat.create({
      nama_perangkat: nama_perangkat,
      lokasi_perangkat: lokasi_perangkat
    })
    session.flash('success','perangkat ditambahkan')
    return response.redirect().back()
  } catch(e) {
    session.flash('error','terjadi error')
    return response.redirect().back()
  }
}).as('post.tambah.perangkat')

Route.get('/admin/device/edit/:id', async ({ view, params }) => {
  const data_perangkat = await IdentitasPerangkat.find(params.id)
  return view.render('pages/admin/edit_device', { data: data_perangkat })
}).as('admin.device.edit')

Route.post('/admin/device/edit/:id', async ({ response, request, session, params }) => {
  const nama_perangkat = request.input('nama_perangkat')
  const lokasi_perangkat = request.input('lokasi_perangkat')

  try {
    const data_perangkat = await IdentitasPerangkat.findByOrFail('id', params.id)
    data_perangkat.nama_perangkat = nama_perangkat
    data_perangkat.lokasi_perangkat = lokasi_perangkat
    await data_perangkat.save()
    session.flash('success','perangkat diubah')
    return response.redirect().back()
  } catch(e) {
    session.flash('error','terjadi error')
    return response.redirect().back()
  }
}).as('post.edit.perangkat')

Route.get('/admin', async ({ view }) => {
  const data_perangkat = await IdentitasPerangkat.all()
  return view.render('pages/admin/index', { data: data_perangkat })
}).as('admin.index')

// Route.get('/admin/device', async ({ view }) => {
//   return view.render('pages/admin/device')
// }).as('admin.device')

Route.get('/admin/device/create', async ({ view }) => {
  return view.render('pages/admin/create_device')
}).as('admin.device.create')
