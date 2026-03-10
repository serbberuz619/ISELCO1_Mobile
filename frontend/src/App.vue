<script setup>
import { ref, onMounted } from 'vue'

// Gagawa tayo ng reactive variable para sa mensahe na manggagaling sa backend.
const apiMessage = ref('Loading from Laravel Backend...')
const apiData = ref(null)
const error = ref(null)

// Function para kunin ang data mula sa Laravel Backend API
// Ginagamit ang fetch API para hindi na natin kailangan ng extra libraries at iwas spaghetti code.
const fetchFromLaravel = async () => {
  try {
    // Tinatawag ang endpoint sa Laravel test controller natin
    const response = await fetch('http://localhost:8000/api/test-message', {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
      }
    })
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    
    const result = await response.json()
    // In-uupdate natin ang reactive variables sa Vue
    apiMessage.value = result.message
    apiData.value = result.data
  } catch (err) {
    console.error('Network Error:', err)
    error.value = 'Hindi makakonekta sa Laravel Backend. Siguraduhing naka-run ang server.'
    apiMessage.value = 'Failed to load.'
  }
}

// Tatawagin ang function pagka-mount ng component.
onMounted(() => {
  fetchFromLaravel()
})
</script>

<template>
  <div class="container">
    <h1>ISELCO1_Mobile Frontend (Vue)</h1>
    
    <!-- Ipinapakita ang error kung meron -->
    <div v-if="error" class="error-box">
      {{ error }}
    </div>

    <!-- Ipinapakita ang status at mensahe kapag nakonekta ng maayos -->
    <div v-else class="success-box">
      <h2>Status mula sa Backend:</h2>
      <p class="message">{{ apiMessage }}</p>

      <div v-if="apiData" class="details">
        <p><strong>Project Name:</strong> {{ apiData.project_name }}</p>
        <p><strong>Description:</strong> {{ apiData.description }}</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.container {
  max-width: 600px;
  margin: 0 auto;
  padding: 2rem;
  text-align: center;
  font-family: sans-serif;
}

.success-box {
  background-color: #d1fae5;
  color: #065f46;
  padding: 1rem;
  border-radius: 8px;
  margin-top: 1rem;
}

.error-box {
  background-color: #fee2e2;
  color: #991b1b;
  padding: 1rem;
  border-radius: 8px;
  margin-top: 1rem;
}

.message {
  font-size: 1.25rem;
  font-weight: bold;
}

.details {
  margin-top: 1rem;
  text-align: left;
  background: rgba(255, 255, 255, 0.5);
  padding: 10px;
  border-radius: 5px;
}
</style>
