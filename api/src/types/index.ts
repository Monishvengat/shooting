export interface ApiResponse<T> {
    success: boolean;
    data?: T;
    message?: string;
}

export interface User {
    id: string;
    name: string;
    email: string;
}

export interface CreateUserRequest {
    name: string;
    email: string;
}

export interface UpdateUserRequest {
    id: string;
    name?: string;
    email?: string;
}