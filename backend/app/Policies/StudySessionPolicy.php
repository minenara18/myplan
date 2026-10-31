<?php

namespace App\Policies;

use App\Models\StudySession;
use App\Models\User;

final class StudySessionPolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }

    public function view(User $user, StudySession $session): bool
    {
        return $session->user_id === $user->id;
    }

    public function create(User $user): bool
    {
        return true;
    }

    public function update(User $user, StudySession $session): bool
    {
        return $session->user_id === $user->id;
    }

    public function delete(User $user, StudySession $session): bool
    {
        return $session->user_id === $user->id;
    }
}
